import 'package:flutter/material.dart';
import 'package:samapp/models/legacy_capsule.dart';
import 'package:intl/intl.dart';

class ViewLegacyCapsuleScreen extends StatelessWidget {
  final LegacyCapsule capsule;

  const ViewLegacyCapsuleScreen({super.key, required this.capsule});

  Widget _buildRecipientInfo(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label $value',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capsule from ${DateFormat.yMMMd().format(capsule.creationDate)}'),
      ),
      body: Container(
        padding: const EdgeInsets.all(24.0),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_email_read,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'A message from your past self:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              if (capsule.recipientName != null && capsule.recipientName!.isNotEmpty)
                _buildRecipientInfo(context, 'Sent to:', capsule.recipientName!, Icons.person),
              if (capsule.recipientEmail != null && capsule.recipientEmail!.isNotEmpty)
                _buildRecipientInfo(context, 'Recipient Email:', capsule.recipientEmail!, Icons.email),
              if ((capsule.recipientName != null && capsule.recipientName!.isNotEmpty) || (capsule.recipientEmail != null && capsule.recipientEmail!.isNotEmpty))
                const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Text(
                  capsule.content,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
