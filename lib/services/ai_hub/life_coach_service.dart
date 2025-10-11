import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:samapp/models/journal_entry.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LifeCoachService {
  static const String _consentKey = 'lifeCoachConsentGiven';

  final List<String> _staticReflections = [
    'What is one small, kind thing you can do for yourself today?',
    'Remember to breathe. A single deep breath can be a moment of peace.',
    'What are you grateful for in this exact moment, no matter how small?',
    'Acknowledge the progress you\'ve made, even if the journey isn\'t over.',
    'What does your body need right now? A stretch, a glass of water, a moment of rest?',
  ];

  Future<void> getReflection(BuildContext context) async {
    final settingsBox = Hive.box('settings');
    final bool consentGiven = settingsBox.get(_consentKey) ?? false;

    if (!consentGiven) {
      final bool userConsented = await _showConsentDialog(context) ?? false;
      if (!userConsented) return;
      await settingsBox.put(_consentKey, true);
    }

    _fetchAndShowReflection(context);
  }

  Future<void> _fetchAndShowReflection(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (!isOnline) {
        throw const SocketException('No Internet');
      }

      final journalContext = _getJournalContext();
      if (journalContext.isEmpty) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        _showErrorDialog(context, 'Not Enough Data',
            'You need at least 3 journal entries for the AI to provide a meaningful reflection. Please write more in your journal and try again.');
        return;
      }

      final prompt =
          'You are a reflective journal assistant. Your role is to identify recurring themes, sentiments, or behavioral patterns from the user\'s journal entries. Present your findings as a gentle, non-judgmental, and supportive reflection, acting as a mirror. Do NOT give advice, make diagnoses, or use commanding language. Frame your feedback as observations. Start with a phrase like \'I\'ve noticed that...\' or \'It seems like...\'. Keep the reflection concise (under 100 words). Here are the user\'s journal entries:\n\n$journalContext';

      final url = Uri.parse(dotenv.env['CREATIVE_MUSE_API_URL']!);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      ).timeout(const Duration(seconds: 45));

      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reflection = data['muse'];
        _showReflectionDialog(context, reflection);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      if (e is SocketException || e is TimeoutException) {
        final staticReflection = _getStaticReflection();
        _showReflectionDialog(context, staticReflection);
      } else {
        _showErrorDialog(context, 'An Error Occurred',
            'Could not get a reflection. Please try again later.');
      }
    }
  }

  String _getStaticReflection() {
    final random = Random();
    return _staticReflections[random.nextInt(_staticReflections.length)];
  }

  String _getJournalContext() {
    final journalBox = Hive.box<JournalEntry>('journal_entries');
    if (journalBox.length < 3) return '';

    final entries = journalBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    return entries
        .map((j) =>
            'Date: ${j.date.toIso8601String().split('T').first}\nMood: ${j.mood.toString().split('.').last}\nEntry: ${j.content}')
        .join('\n\n---\n\n');
  }

  Future<bool?> _showConsentDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Life Coach'),
        content: const SingleChildScrollView(
          child: Text(
            'This feature uses a third-party AI to analyze your private journal entries to provide reflections on your patterns and themes.\n\nYour data is NOT stored or used for training by the AI provider. It is only processed to generate the reflection.\n\nThis is not a substitute for professional therapy. The AI acts as a reflective mirror, not a medical professional.\n\nDo you consent to proceed?',
            style: TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Decline'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('I Consent'),
          ),
        ],
      ),
    );
  }

  void _showReflectionDialog(BuildContext context, String reflection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.psychology, color: Colors.blue),
            SizedBox(width: 12),
            Text('A Reflection For You'),
          ],
        ),
        content: Text(
          '\"$reflection\"',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
