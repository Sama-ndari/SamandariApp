import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 25) // SAFE ID
class ChatMessage extends HiveObject {
  @HiveField(0)
  late String text;

  @HiveField(1)
  late bool isUser;

  @HiveField(2)
  late DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
