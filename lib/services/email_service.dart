import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:samapp/models/legacy_capsule.dart';
import 'package:samapp/services/logging_service.dart';

/// Service for sending legacy capsule emails via Gmail SMTP.
/// 
/// This service handles the email delivery of legacy capsules to recipients
/// when their scheduled open date arrives. It uses Gmail's SMTP server
/// with app-specific passwords for secure authentication.
/// 
/// Prerequisites:
/// - Gmail account with 2-factor authentication enabled
/// - App-specific password generated in Google Account settings
/// - Environment variables configured in .env file:
///   - GMAIL_USER: Your Gmail address
///   - GMAIL_APP_PASSWORD: 16-character app password
/// 
/// Features:
/// - HTML email formatting with beautiful templates
/// - Comprehensive error handling and logging
/// - Validation of email credentials and recipient data
/// - Detailed success/failure reporting
/// 
/// Usage:
/// ```dart
/// final emailService = EmailService();
/// final success = await emailService.sendCapsuleEmail(capsule);
/// if (success) {
///   print('Email sent successfully!');
/// }
/// ```
class EmailService {
  /// Sends a legacy capsule via email to the specified recipient.
  /// 
  /// This method creates a beautifully formatted HTML email containing
  /// the capsule's content and sends it to the recipient's email address.
  /// 
  /// The email includes:
  /// - Personalized subject line with recipient name
  /// - HTML-formatted content with the capsule message
  /// - Creation date and unlock information
  /// - Branded footer with app name
  /// 
  /// Parameters:
  /// - [capsule]: The LegacyCapsule object containing message and recipient info
  /// 
  /// Returns:
  /// - `true` if email was sent successfully
  /// - `false` if sending failed (credentials missing, network error, etc.)
  /// 
  /// The method performs extensive validation and logging:
  /// - Validates environment variables are present
  /// - Checks recipient email is provided
  /// - Logs all steps of the sending process
  /// - Handles both MailerException and general exceptions
  Future<bool> sendCapsuleEmail(LegacyCapsule capsule) async {
    AppLogger.info('Starting email send process for capsule ${capsule.id}');
    
    final user = dotenv.env['GMAIL_USER'];
    final password = dotenv.env['GMAIL_APP_PASSWORD'];

    if (user == null || password == null) {
      AppLogger.error('Email credentials not found in .env file. Please ensure GMAIL_USER and GMAIL_APP_PASSWORD are set');
      return false;
    }

    if (capsule.recipientEmail == null || capsule.recipientEmail!.isEmpty) {
      AppLogger.warning('Recipient email is missing for capsule ${capsule.id}');
      return false;
    }

    AppLogger.debug('Using Gmail account: $user');
    AppLogger.info('Sending capsule to: ${capsule.recipientEmail}');

    final smtpServer = gmail(user, password);

    final message = Message()
      ..from = Address(user, 'SamApp Legacy Capsule')
      ..recipients.add(capsule.recipientEmail!)
      ..subject = 'A Legacy Capsule from ${capsule.recipientName ?? 'a friend'} has been unlocked!'
      ..html = """
      <h1>A message from the past has arrived!</h1>
      <p>This Legacy Capsule was created on ${capsule.creationDate.toLocal().toString().split(' ')[0]} and unlocked today.</p>
      <hr>
      <h2>Message:</h2>
      <p style=\"font-size: 16px; font-style: italic;\">\"${capsule.content}\"</p>
      <hr>
      <p>Sent from your personal assistant, Samandari.</p>
      """;

    try {
      AppLogger.debug('Attempting to send email...');
      final sendReport = await send(message, smtpServer);
      AppLogger.info('Message sent successfully: ${sendReport.toString()}');
      return true;
    } on MailerException catch (e, stackTrace) {
      AppLogger.error('Message not sent - MailerException', e, stackTrace);
      for (var p in e.problems) {
        AppLogger.error('Email problem: ${p.code}: ${p.msg}');
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error sending email', e, stackTrace);
      return false;
    }
  }
}
