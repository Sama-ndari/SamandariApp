import 'package:hive/hive.dart';
import 'package:samapp/models/legacy_capsule.dart';
import 'package:samapp/services/email_service.dart';

class CapsuleCheckService {
  final EmailService _emailService = EmailService();

  Future<void> checkAndSendCapsules() async {
    print('Checking for unlocked capsules to send...');
    final box = Hive.box<LegacyCapsule>('legacy_capsules');
    final now = DateTime.now();

    final List<LegacyCapsule> capsulesToSend = [];

    for (var capsule in box.values) {
      if (capsule.openDate.isBefore(now) && !capsule.isSent && capsule.recipientEmail != null && capsule.recipientEmail!.isNotEmpty) {
        capsulesToSend.add(capsule);
      }
    }

    if (capsulesToSend.isNotEmpty) {
      print('Found ${capsulesToSend.length} capsule(s) to send.');
      for (var capsule in capsulesToSend) {
        bool success = await _emailService.sendCapsuleEmail(capsule);
        if (success) {
          capsule.isSent = true;
          await capsule.save();
          print('Successfully sent capsule ${capsule.id} and marked as sent.');
        }
      }
    } else {
      print('No capsules to send at this time.');
    }
  }
}
