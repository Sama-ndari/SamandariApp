import 'package:hive/hive.dart';
import 'package:samapp/models/ai_chat/chat_message.dart';

part 'conversation.g.dart';

@HiveType(typeId: 24) // SAFE ID
class Conversation extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late DateTime createdAt;

  @HiveField(3)
  late List<ChatMessage> messages;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
  });
}
