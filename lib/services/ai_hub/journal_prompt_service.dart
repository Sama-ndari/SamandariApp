import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:samapp/data/journal_prompts.dart';

class JournalPromptService {
  /// Fetches a new prompt, preferring an AI-generated one if online.
  Future<String> getDynamicPrompt() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        return await _getAiPrompt();
      } else {
        return getStaticPrompt();
      }
    } catch (e) {
      // If any error occurs (timeout, etc.), fall back to a static prompt.
      return getStaticPrompt();
    }
  }

  /// Always returns a random prompt from the local list.
  String getStaticPrompt() {
    final random = Random();
    return staticJournalPrompts[random.nextInt(staticJournalPrompts.length)];
  }

  Future<String> _getAiPrompt() async {
    final prompt =
        'Generate a single, profound, and open-ended question that would inspire deep self-reflection for a journal entry. The question should be under 20 words and unique.';

    final url = Uri.parse(dotenv.env['CREATIVE_MUSE_API_URL']!);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': prompt}),
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['muse'].replaceAll('"', '');
    } else {
      throw Exception('Failed to get AI prompt');
    }
  }
}
