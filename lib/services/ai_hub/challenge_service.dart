import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:samapp/services/dynamic_challenge_service.dart';

class ChallengeService {
  Future<void> getDynamicChallenge(BuildContext context) async {
    final challengeService = DynamicChallengeService();
    final analysisResult = challengeService.findChallengeArea();

    if (analysisResult.category == 'Success') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(children: [Icon(analysisResult.icon, color: Colors.green), const SizedBox(width: 12), const Text('Great Job!')]),
          content: Text(analysisResult.description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final random = Random();
      final promptTemplates = [
        'Generate a single, fun, and simple one-day challenge that is easy to start. The tone should be encouraging, not demanding. The challenge is for a user where: ${analysisResult.description}',
        'Based on the following situation, what is one small, positive action the user could take today? Situation: ${analysisResult.description}',
        'Create a fun, bite-sized mission for someone in this situation: ${analysisResult.description}. Make it sound exciting and achievable in a single day.',
        'I\'m a user who is currently facing this: "${analysisResult.description}". Suggest a simple, one-day activity to help me get back on track. Be creative and supportive.',
      ];
      final prompt = promptTemplates[random.nextInt(promptTemplates.length)];

      final url = Uri.parse(dotenv.env['CREATIVE_MUSE_API_URL']!);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      ).timeout(const Duration(seconds: 20));

      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final challenge = data['muse'];

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(analysisResult.icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('A Challenge for Your ${analysisResult.category}'),
                ),
              ],
            ),
            content: Text(
              challenge,
              style: const TextStyle(fontSize: 18, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Decline'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Challenge accepted! (Functionality coming soon)')),
                  );
                },
                child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed to load challenge. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      String title = 'An Error Occurred';
      String content = 'Could not fetch a dynamic challenge. Please try again later.';

      if (e is SocketException) {
        title = 'No Internet Connection';
        content = 'Please check your network connection and try again.';
      } else if (e is TimeoutException) {
        title = 'Request Timed Out';
        content = 'The server took too long to respond. Please try again later.';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [ TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')) ],
        ),
      );
    }
  }
}
