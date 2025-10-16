import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:samapp/models/legacy_capsule.dart';

class EmailService {
  Future<bool> sendCapsuleEmail(LegacyCapsule capsule) async {
    print('[EmailService] Starting email send process for capsule ${capsule.id}');
    
    final user = dotenv.env['GMAIL_USER'];
    final password = dotenv.env['GMAIL_APP_PASSWORD'];

    if (user == null || password == null) {
      print('[EmailService] ✗ Email credentials not found in .env file.');
      print('[EmailService] Please ensure GMAIL_USER and GMAIL_APP_PASSWORD are set in .env');
      return false;
    }

    if (capsule.recipientEmail == null || capsule.recipientEmail!.isEmpty) {
      print('[EmailService] ✗ Recipient email is missing for capsule ${capsule.id}');
      return false;
    }

    print('[EmailService] Using Gmail account: $user');
    print('[EmailService] Sending to: ${capsule.recipientEmail}');

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
      print('[EmailService] Attempting to send email...');
      final sendReport = await send(message, smtpServer);
      print('[EmailService] ✓ Message sent successfully: ' + sendReport.toString());
      return true;
    } on MailerException catch (e) {
      print('[EmailService] ✗ Message not sent - MailerException: ' + e.toString());
      // Optionally, rethrow or handle specific exceptions
      for (var p in e.problems) {
        print('[EmailService] Problem: ${p.code}: ${p.msg}');
      }
      return false;
    } catch (e) {
      print('[EmailService] ✗ Unexpected error sending email: $e');
      return false;
    }
  }
}
