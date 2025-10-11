import 'package:hive/hive.dart';
import 'package:samapp/models/ai_chat/conversation.dart';
import 'package:samapp/models/ai_chat/chat_message.dart';
import 'package:uuid/uuid.dart';

class AiChatHistoryService {
  final Box<Conversation> _conversationBox = Hive.box('conversations');
  final _uuid = const Uuid();

  // Get all conversations
  List<Conversation> getAllConversations() {
    return _conversationBox.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get a specific conversation
  Conversation? getConversation(String id) {
    return _conversationBox.get(id);
  }

  // Create a new conversation
  Future<Conversation> createNewConversation() async {
    final newConversation = Conversation(
      id: _uuid.v4(),
      title: 'New Chat',
      createdAt: DateTime.now(),
      messages: [],
    );
    await _conversationBox.put(newConversation.id, newConversation);
    return newConversation;
  }

  // Add a message to a conversation
  Future<void> addMessageToConversation(String conversationId, ChatMessage message) async {
    final conversation = getConversation(conversationId);
    if (conversation != null) {
      conversation.messages.add(message);

      // If this is the first user message, update the title
      if (conversation.messages.where((m) => m.isUser).length == 1) {
        conversation.title = message.text.length > 30 ? '${message.text.substring(0, 30)}...' : message.text;
      }

      await conversation.save();
    }
  }

  // Delete a conversation
  Future<void> deleteConversation(String id) async {
    await _conversationBox.delete(id);
  }
}
