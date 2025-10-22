import 'package:hive/hive.dart';
import 'package:samapp/models/legacy_capsule.dart';
import 'package:samapp/services/email_service.dart';
import 'package:samapp/services/logging_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service responsible for checking and sending legacy capsules via email.
/// 
/// This service monitors legacy capsules stored in Hive database and automatically
/// sends them via email when their scheduled open date arrives. It includes
/// connectivity checks to ensure emails are only sent when internet is available.
/// 
/// Features:
/// - Automatic capsule checking based on open dates
/// - Internet connectivity validation before sending
/// - Comprehensive logging for debugging
/// - Error handling for failed email sends
/// - Capsule status tracking (sent/not sent)
class CapsuleCheckService {
  /// Email service instance for sending capsule emails
  final EmailService _emailService = EmailService();

  /// Checks for unlocked legacy capsules and sends them via email.
  /// 
  /// This method performs the following operations:
  /// 1. Validates internet connectivity
  /// 2. Retrieves all legacy capsules from Hive storage
  /// 3. Filters capsules that are ready to be sent (past open date, not already sent)
  /// 4. Attempts to send each eligible capsule via email
  /// 5. Updates capsule status upon successful sending
  /// 
  /// The method includes extensive logging to help with debugging and monitoring.
  /// 
  /// Throws: No exceptions are thrown - all errors are caught and logged
  /// Returns: Future<void> that completes when all operations are finished
  Future<void> checkAndSendCapsules() async {
    AppLogger.info('Checking for unlocked capsules to send...');

    // 1. Check for internet connection first
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      AppLogger.warning('No internet connection. Skipping email sending check.');
      return; // Stop if offline
    }

    final box = Hive.box<LegacyCapsule>('legacy_capsules');
    final now = DateTime.now();
    
    AppLogger.debug('Current time: $now');
    AppLogger.debug('Total capsules in box: ${box.values.length}');

    final List<LegacyCapsule> capsulesToSend = [];

    for (var capsule in box.values) {
      AppLogger.trace('Checking capsule ${capsule.id}: openDate=${capsule.openDate}, isSent=${capsule.isSent}, email=${capsule.recipientEmail}');
      
      if (capsule.openDate.isBefore(now) && !capsule.isSent && capsule.recipientEmail != null && capsule.recipientEmail!.isNotEmpty) {
        capsulesToSend.add(capsule);
        AppLogger.debug('Added capsule ${capsule.id} to send queue');
      }
    }

    if (capsulesToSend.isNotEmpty) {
      AppLogger.info('Found ${capsulesToSend.length} capsule(s) to send');
      for (var capsule in capsulesToSend) {
        try {
          AppLogger.info('Attempting to send capsule ${capsule.id} to ${capsule.recipientEmail}');
          bool success = await _emailService.sendCapsuleEmail(capsule);
          if (success) {
            capsule.isSent = true;
            await capsule.save();
            AppLogger.info('Successfully sent capsule ${capsule.id} and marked as sent');
          } else {
            AppLogger.warning('Failed to send capsule ${capsule.id} - email service returned false');
          }
        } catch (e, stackTrace) {
          AppLogger.error('Failed to send capsule ${capsule.id}', e, stackTrace);
          // The app will no longer freeze. It will retry next time.
        }
      }
    } else {
      AppLogger.debug('No capsules to send at this time');
    }
  }
}
