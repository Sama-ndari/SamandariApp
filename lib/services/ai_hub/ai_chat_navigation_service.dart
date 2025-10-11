import 'package:flutter/material.dart';
import 'package:samapp/screens/ai_hub/ai_chat_screen.dart';
import 'package:samapp/services/connectivity_service.dart';

class AiChatNavigationService {
  final ConnectivityService _connectivityService = ConnectivityService();

  Future<void> navigateToAiChat(BuildContext context) async {
    final hasConnection = await _connectivityService.hasActiveInternetConnection();
    if (context.mounted) {
      if (hasConnection) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AiChatScreen()));
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('No Internet Connection'),
              content: const Text('Please check your connection and try again.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }
}
