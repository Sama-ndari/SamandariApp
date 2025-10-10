import 'package:flutter/material.dart';

class VoiceAssistantService {
  void showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice Assistant / Chatbot coming soon!')),
    );
  }
}
