import 'package:hive/hive.dart';
import 'package:samapp/models/legacy_capsule.dart';
import 'package:samapp/services/email_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CapsuleCheckService {
  final EmailService _emailService = EmailService();

  Future<void> checkAndSendCapsules() async {
    print('[CapsuleCheckService] Checking for unlocked capsules to send...');

    // 1. Check for internet connection first
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print('[CapsuleCheckService] No internet connection. Skipping email sending check.');
      return; // Stop if offline
    }

    final box = Hive.box<LegacyCapsule>('legacy_capsules');
    final now = DateTime.now();
    
    print('[CapsuleCheckService] Current time: $now');
    print('[CapsuleCheckService] Total capsules in box: ${box.values.length}');

    final List<LegacyCapsule> capsulesToSend = [];

    for (var capsule in box.values) {
      print('[CapsuleCheckService] Checking capsule ${capsule.id}:');
      print('  - Open date: ${capsule.openDate}');
      print('  - Is sent: ${capsule.isSent}');
      print('  - Recipient email: ${capsule.recipientEmail}');
      print('  - Open date before now: ${capsule.openDate.isBefore(now)}');
      
      if (capsule.openDate.isBefore(now) && !capsule.isSent && capsule.recipientEmail != null && capsule.recipientEmail!.isNotEmpty) {
        capsulesToSend.add(capsule);
        print('  ✓ Added to send queue');
      } else {
        print('  ✗ Not eligible for sending');
      }
    }

    if (capsulesToSend.isNotEmpty) {
      print('[CapsuleCheckService] Found ${capsulesToSend.length} capsule(s) to send.');
      for (var capsule in capsulesToSend) {
        try {
          print('[CapsuleCheckService] Attempting to send capsule ${capsule.id} to ${capsule.recipientEmail}');
          bool success = await _emailService.sendCapsuleEmail(capsule);
          if (success) {
            capsule.isSent = true;
            await capsule.save();
            print('[CapsuleCheckService] ✓ Successfully sent capsule ${capsule.id} and marked as sent.');
          } else {
            print('[CapsuleCheckService] ✗ Failed to send capsule ${capsule.id} - email service returned false');
          }
        } catch (e) {
          print('[CapsuleCheckService] ✗ Failed to send capsule ${capsule.id}: $e');
          // The app will no longer freeze. It will retry next time.
        }
      }
    } else {
      print('[CapsuleCheckService] No capsules to send at this time.');
    }
  }
}
