import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:samapp/data/quotes_data.dart';
import 'package:samapp/models/quote.dart';
import 'package:samapp/services/logging_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum QuoteCategory { inspirational, scripture, stoic, techAndBusiness }

class DailyInspirationWidget extends StatefulWidget {
  const DailyInspirationWidget({super.key});

  @override
  State<DailyInspirationWidget> createState() => _DailyInspirationWidgetState();
}

class _DailyInspirationWidgetState extends State<DailyInspirationWidget> {
  QuoteCategory _currentCategory = QuoteCategory.inspirational;
  int? _currentIndex;
  List<Quote>? _currentQuoteList;

  @override
  void initState() {
    super.initState();
    _setRandomCategoryAndQuote();
  }

  Future<void> _setRandomCategoryAndQuote() async {
    final random = Random();
    final categories = QuoteCategory.values;
    final newCategory = categories[random.nextInt(categories.length)];

    final connectivityResult = await (Connectivity().checkConnectivity());
    final isOnline = connectivityResult != ConnectivityResult.none;

    Quote? dynamicQuote;
    if (isOnline) {
      dynamicQuote = await _getDynamicQuote(newCategory);
    }

    if (mounted) {
      setState(() {
        _currentCategory = newCategory;
        if (dynamicQuote != null) {
          _currentQuoteList = [dynamicQuote];
          _currentIndex = 0;
        } else {
          // Fallback to static list
          _setQuoteListForCategory();
          _currentIndex = random.nextInt(_currentQuoteList!.length);
        }
      });
    }
  }

  Future<Quote?> _getDynamicQuote(QuoteCategory category) async {
    try {
      final categoryName = category.toString().split('.').last;
      final prompt = 'Generate one short, original quote about $categoryName. The quote must be under 25 words and sound inspiring and human. Respond ONLY in this exact Dart format, nothing else:\n\nQuote(text: "<quote text>", author: "<author name>")';

      final url = Uri.parse('https://creative-muse-backend.vercel.app/api/get-muse');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body)['muse'];
        // Use a regular expression to parse the custom format
        final regExp = RegExp(r'Quote\(text: "(.*?)", author: "(.*?)"\)');
        final match = regExp.firstMatch(responseBody);

        if (match != null && match.groupCount == 2) {
          final text = match.group(1)!;
          final author = match.group(2)!;
          return Quote(text: text, author: author);
        }
      }
    } catch (e) {
      // Silently fail and fallback to static quote
      AppLogger.error('Failed to get dynamic quote', e);
    }
    return null;
  }

  void _setQuoteListForCategory() {
    switch (_currentCategory) {
      case QuoteCategory.inspirational:
        _currentQuoteList = inspirationalQuotes;
        break;
      case QuoteCategory.scripture:
        _currentQuoteList = scriptures;
        break;
      case QuoteCategory.stoic:
        _currentQuoteList = stoicQuotes;
        break;
      case QuoteCategory.techAndBusiness:
        _currentQuoteList = techQuotes;
        break;
    }
  }

  void _switchCategory() {
    setState(() {
      final currentCategoryIndex = QuoteCategory.values.indexOf(_currentCategory);
      final nextCategoryIndex = (currentCategoryIndex + 1) % QuoteCategory.values.length;
      _currentCategory = QuoteCategory.values[nextCategoryIndex];
      _setQuoteListForCategory();
      _currentIndex = 0; // Always start with the first quote of the new category
    });
  }

  void _nextQuote() {
    setState(() {
      // 60% chance to switch category
      if (Random().nextInt(10) < 6) {
        _setRandomCategoryAndQuote();
      } else {
        // If we are showing a dynamic quote, fetch a new one
        if (_currentQuoteList?.length == 1) {
          _setRandomCategoryAndQuote();
        } else {
          _currentIndex = (_currentIndex! + 1) % _currentQuoteList!.length;
        }
      }
    });
  }

  void _previousQuote() {
    setState(() {
      // 60% chance to switch category
      if (Random().nextInt(10) < 6) {
        _setRandomCategoryAndQuote();
      } else {
        // If we are showing a dynamic quote, fetch a new one
        if (_currentQuoteList?.length == 1) {
          _setRandomCategoryAndQuote();
        } else {
          _currentIndex = (_currentIndex! - 1 + _currentQuoteList!.length) % _currentQuoteList!.length;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // If the quote list hasn't been initialized yet, show a loading indicator.
    if (_currentQuoteList == null || _currentIndex == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final quote = _currentQuoteList![_currentIndex!];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getCategoryTitle(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            '"${quote.text}"',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            '- ${quote.author}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousQuote,
                tooltip: 'Previous',
              ),
              IconButton(
                icon: Icon(
                  _getCategoryIcon(),
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: _switchCategory,
                tooltip: 'Switch Category',
                iconSize: 28,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _nextQuote,
                tooltip: 'Next',
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (_currentCategory) {
      case QuoteCategory.inspirational:
        return Icons.lightbulb_outline;
      case QuoteCategory.scripture:
        return Icons.book_outlined;
      case QuoteCategory.stoic:
        return Icons.balance;
      case QuoteCategory.techAndBusiness:
        return Icons.business_center;
    }
  }

  String _getCategoryTitle() {
    switch (_currentCategory) {
      case QuoteCategory.inspirational:
        return 'Daily Inspiration';
      case QuoteCategory.scripture:
        return 'Verse of the Day';
      case QuoteCategory.stoic:
        return 'Stoic Wisdom';
      case QuoteCategory.techAndBusiness:
        return 'Tech & Business Insights';
    }
  }
}
