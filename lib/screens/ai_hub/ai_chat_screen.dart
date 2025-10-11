import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:samapp/services/ai_hub/ai_chat_service.dart';

import 'package:samapp/services/ai_hub/ai_chat_history_service.dart';
import 'package:samapp/models/ai_chat/conversation.dart';
import 'package:samapp/models/ai_chat/chat_message.dart' as model;

class ChatMessage { // This is a view model, different from the Hive model
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isTtsEnabled = true;
  final AiChatHistoryService _historyService = AiChatHistoryService();
  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
  final AiChatService _chatService = AiChatService();
  bool _isTyping = false;
  bool _useContext = false;
  bool _isRecordingLocked = false;
  late AnimationController _blinkingController;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _blinkingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _loadConversations();
    _textController.addListener(() {
      setState(() {}); // Rebuild to show/hide send button
    });
  }

  void _loadConversations() async {
    final conversations = _historyService.getAllConversations();
    if (conversations.isEmpty) {
      await _createNewConversation();
    } else {
      setState(() {
        _conversations = conversations;
        _currentConversation = conversations.first;
      });
    }
  }

  Future<void> _createNewConversation() async {
    final newConversation = await _historyService.createNewConversation();
    setState(() {
      _conversations.insert(0, newConversation);
      _currentConversation = newConversation;
    });
  }

  @override
  void dispose() {
    _blinkingController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    if (!_speechEnabled) return;
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening({bool cancel = false}) async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });

    // Only auto-submit for non-locked, non-cancelled recordings
    if (!_isRecordingLocked && _textController.text.isNotEmpty && !cancel) {
      _handleSubmitted(_textController.text);
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _textController.text = result.recognizedWords;
    });
  }

  Future<void> _speak(String text) async {
    if (_isTtsEnabled) {
      await _flutterTts.speak(text);
    }
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty || _currentConversation == null) return;

    final userMessage = model.ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    await _historyService.addMessageToConversation(_currentConversation!.id, userMessage);

    _textController.clear();
    setState(() {
      _isTyping = true;
    });

    final response = await _chatService.getResponse(text, _useContext);

    final aiMessage = model.ChatMessage(
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    );
    await _historyService.addMessageToConversation(_currentConversation!.id, aiMessage);

    setState(() {
      _isTyping = false;
    });

    _speak(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        title: Text(_currentConversation?.title ?? 'AI Assistant'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _useContext = !_useContext;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Row(
                  children: [
                    Icon(
                      _useContext ? Icons.person_search : Icons.public,
                      color: _useContext ? Theme.of(context).colorScheme.primary : Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _useContext ? 'Personal' : 'General',
                      style: TextStyle(
                        color: _useContext ? Theme.of(context).colorScheme.primary : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(_isTtsEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              setState(() {
                _isTtsEnabled = !_isTtsEnabled;
              });
            },
            tooltip: _isTtsEnabled ? 'Disable Text-to-Speech' : 'Enable Text-to-Speech',
          ),
        ],
      ),
      drawer: _buildConversationsDrawer(),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: _useContext ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                  reverse: true,
                  itemCount: _currentConversation?.messages.length ?? 0,
                  itemBuilder: (context, index) {
                    // To show latest messages at the bottom
                    final message = _currentConversation!.messages.reversed.toList()[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),
              if (_isTyping)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [CircularProgressIndicator()],
                  ),
                ),
              const Divider(height: 1.0),
              _buildTextComposer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(model.ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: message.isUser ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsDrawer() {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text('Chats'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () async {
                  await _createNewConversation();
                  Navigator.of(context).pop(); // Close drawer
                },
                tooltip: 'New Chat',
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conversation = _conversations[index];
                final isSelected = conversation.id == _currentConversation?.id;
                return ListTile(
                  title: Text(conversation.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${conversation.messages.length} messages'),
                  selected: isSelected,
                  selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      _currentConversation = conversation;
                    });
                    Navigator.of(context).pop(); // Close drawer
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Chat?'),
                          content: const Text('This action cannot be undone.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ) ?? false;

                      if (confirm) {
                        final isDeletingCurrent = conversation.id == _currentConversation?.id;
                        await _historyService.deleteConversation(conversation.id);
                        setState(() {
                          _conversations.removeWhere((c) => c.id == conversation.id);
                          if (isDeletingCurrent) {
                            if (_conversations.isNotEmpty) {
                              _currentConversation = _conversations.first;
                            } else {
                              // This will trigger the creation of a new chat
                              _currentConversation = null;
                            }
                          }
                        });
                        if (_currentConversation == null) {
                          await _createNewConversation();
                        }
                        if (isDeletingCurrent) {
                           Navigator.of(context).pop(); // Close drawer
                        }
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    bool isRecording = _isListening || _isRecordingLocked;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isRecording)
            FadeTransition(
              opacity: _blinkingController,
              child: const Icon(Icons.circle, color: Colors.red, size: 12),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration.collapsed(
                hintText: isRecording ? 'Listening...' : 'Send a message',
              ),
              readOnly: isRecording,
              onChanged: (text) => setState(() {}), // Update UI when text changes
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              minLines: 1,
            ),
          ),
          _buildVoiceAndSendButton(),
        ],
      ),
    );
  }

  Widget _buildVoiceAndSendButton() {
    if (_isRecordingLocked) {
      return IconButton(
        icon: const Icon(Icons.stop_circle, color: Colors.red, size: 30),
        onPressed: () {
          // Stop listening but don't clear the lock state immediately,
          // so _stopListening knows not to auto-send.
          _speechToText.stop();
          setState(() {
            _isRecordingLocked = false;
            _isListening = false;
          });
        },
      );
    }

    if (_textController.text.isNotEmpty && !_isListening) {
      return IconButton(
        icon: const Icon(Icons.send, color: Colors.blue),
        onPressed: () => _handleSubmitted(_textController.text),
      );
    }

    return GestureDetector(
      onLongPressStart: (details) => _startListening(),
      onLongPressEnd: (details) => _stopListening(),
      onLongPressMoveUpdate: (details) {
        if (details.localOffsetFromOrigin.dy < -50 && !_isRecordingLocked) {
          setState(() {
            _isRecordingLocked = true;
          });
        }
        if (details.localOffsetFromOrigin.dx < -50) {
          _stopListening(cancel: true);
        }
      },
      child: Icon(
        Icons.mic,
        color: _isListening ? Colors.red : Theme.of(context).colorScheme.primary,
        size: 30,
      ),
    );
  }
}
