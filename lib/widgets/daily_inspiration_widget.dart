import 'dart:math';

import 'package:flutter/material.dart';
import 'package:samapp/data/quotes_data.dart';
import 'package:samapp/models/quote.dart';

enum QuoteCategory { inspirational, scripture, stoic, techAndBusiness }

class DailyInspirationWidget extends StatefulWidget {
  const DailyInspirationWidget({super.key});

  @override
  State<DailyInspirationWidget> createState() => _DailyInspirationWidgetState();
}

class _DailyInspirationWidgetState extends State<DailyInspirationWidget> {
  QuoteCategory _currentCategory = QuoteCategory.inspirational;
  late int _currentIndex;
  late List<Quote> _currentQuoteList;

  @override
  void initState() {
    super.initState();
    _currentQuoteList = inspirationalQuotes;
    _currentIndex = Random().nextInt(_currentQuoteList.length);
  }

  void _switchCategory() {
    setState(() {
      switch (_currentCategory) {
        case QuoteCategory.inspirational:
          _currentCategory = QuoteCategory.scripture;
          _currentQuoteList = scriptures;
          break;
        case QuoteCategory.scripture:
          _currentCategory = QuoteCategory.stoic;
          _currentQuoteList = stoicQuotes;
          break;
        case QuoteCategory.stoic:
          _currentCategory = QuoteCategory.techAndBusiness;
          _currentQuoteList = techQuotes;
          break;
        case QuoteCategory.techAndBusiness:
          _currentCategory = QuoteCategory.inspirational;
          _currentQuoteList = inspirationalQuotes;
          break;
      }
      _currentIndex = 0; // Always start with the first quote of the new category
    });
  }

  void _nextQuote() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _currentQuoteList.length;
    });
  }

  void _previousQuote() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _currentQuoteList.length) % _currentQuoteList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quote = _currentQuoteList[_currentIndex];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
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
