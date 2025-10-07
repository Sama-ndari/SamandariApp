import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:samapp/models/legacy_capsule.dart';
import 'package:intl/intl.dart';

class ShareLegacyCapsuleScreen extends StatelessWidget {
  final LegacyCapsule capsule;

  const ShareLegacyCapsuleScreen({super.key, required this.capsule});

  @override
  Widget build(BuildContext context) {
    // This is a placeholder. In a real app, you would have a domain.
    final shareableLink = 'https://samandari.com/capsule/${capsule.id}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Your Capsule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.outgoing_mail,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Your capsule for ${capsule.recipientName} is sealed!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'It can be opened on or after ${DateFormat.yMMMd().format(capsule.openDate)}.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 40),
            Text(
              'Share this link with them:',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                shareableLink,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: shareableLink));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard!')),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy Link'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
