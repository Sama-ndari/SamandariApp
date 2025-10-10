import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:samapp/models/legacy_capsule.dart';

class EmailService {
  Future<bool> sendCapsuleEmail(LegacyCapsule capsule) async {
    final user = dotenv.env['GMAIL_USER'];
    final password = dotenv.env['GMAIL_APP_PASSWORD'];

    if (user == null || password == null) {
      print('Email credentials not found in .env file.');
      return false;
    }

    if (capsule.recipientEmail == null || capsule.recipientEmail!.isEmpty) {
      print('Recipient email is missing.');
      return false;
    }

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
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      return true;
    } on MailerException catch (e) {
      print('Message not sent. \n' + e.toString());
      // Optionally, rethrow or handle specific exceptions
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      return false;
    }
  }
}
