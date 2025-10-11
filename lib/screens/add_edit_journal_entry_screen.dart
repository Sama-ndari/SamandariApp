import 'package:flutter/material.dart';
import 'package:samapp/models/journal_entry.dart';
import 'package:samapp/services/journal_service.dart';
import 'package:samapp/services/ai_hub/journal_prompt_service.dart';

class AddEditJournalEntryScreen extends StatefulWidget {
  final JournalEntry? entry;

  const AddEditJournalEntryScreen({super.key, this.entry});

  @override
  State<AddEditJournalEntryScreen> createState() => _AddEditJournalEntryScreenState();
}

class _AddEditJournalEntryScreenState extends State<AddEditJournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _journalService = JournalService();
  final _promptService = JournalPromptService();
  late TextEditingController _contentController;

  String _currentPrompt = '';
  bool _isLoadingPrompt = false;

  late Mood _mood;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.entry?.content ?? '');
    _mood = widget.entry?.mood ?? Mood.neutral;
    _tags = widget.entry?.tags ?? [];
    _loadInitialPrompt();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _loadInitialPrompt() {
    setState(() {
      _currentPrompt = _promptService.getStaticPrompt();
    });
  }

  void _getNewStaticPrompt() {
    setState(() {
      _currentPrompt = _promptService.getStaticPrompt();
    });
  }

  Future<void> _getNewDynamicPrompt() async {
    setState(() {
      _isLoadingPrompt = true;
    });

    try {
      final prompt = await _promptService.getDynamicPrompt();
      setState(() {
        _currentPrompt = prompt;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get a new prompt. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoadingPrompt = false;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newEntry = JournalEntry()
        ..id = widget.entry?.id ?? ''
        ..content = _contentController.text
        ..mood = _mood
        ..tags = _tags
        ..date = widget.entry?.date ?? DateTime.now();

      if (widget.entry == null) {
        _journalService.addJournalEntry(newEntry);
      } else {
        _journalService.updateJournalEntry(newEntry);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'Add Journal Entry' : 'Edit Journal Entry'),
        actions: [
          if (widget.entry != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Journal Entry'),
                    content: const Text('Are you sure you want to delete this entry?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          _journalService.deleteJournalEntry(widget.entry!.id);
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildPromptDisplay(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Your Thoughts',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'How are you feeling?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Mood.values.map((mood) {
                  final isSelected = _mood == mood;
                  final moodName = mood.toString().split('.').last;
                  final formattedMood = moodName[0].toUpperCase() + moodName.substring(1);
                  final moodColor = _getMoodColor(mood);
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _mood = mood;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? moodColor.withOpacity(0.2) : Colors.grey[100],
                        border: Border.all(
                          color: isSelected ? moodColor : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getMoodIcon(mood),
                            color: isSelected ? moodColor : Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formattedMood,
                            style: TextStyle(
                              color: isSelected ? moodColor : Colors.grey[800],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.entry == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptDisplay() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.lightbulb_outline, color: colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentPrompt,
              style: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(width: 8),
          _isLoadingPrompt
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
              : Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.shuffle, color: colorScheme.secondary),
                      tooltip: 'Get a static prompt',
                      onPressed: _getNewStaticPrompt,
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: colorScheme.primary),
                      tooltip: 'Get an AI-powered prompt',
                      onPressed: _getNewDynamicPrompt,
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Color _getMoodColor(Mood mood) {
    switch (mood) {
      case Mood.happy:
        return const Color(0xFF4CAF50);
      case Mood.sad:
        return const Color(0xFF2196F3);
      case Mood.neutral:
        return const Color(0xFF9E9E9E);
      case Mood.excited:
        return const Color(0xFFFF9800);
      case Mood.calm:
        return const Color(0xFF009688);
      case Mood.anxious:
        return const Color(0xFF9C27B0);
      case Mood.grateful:
        return const Color(0xFFE91E63);
      case Mood.angry:
        return const Color(0xFFF44336);
      case Mood.loved:
        return const Color(0xFFFF4081);
      case Mood.peaceful:
        return const Color(0xFF00BCD4);
      case Mood.stressed:
        return const Color(0xFFFF5722);
      case Mood.energetic:
        return const Color(0xFFFFEB3B);
      case Mood.tired:
        return const Color(0xFF607D8B);
      case Mood.hopeful:
        return const Color(0xFF8BC34A);
      case Mood.lonely:
        return const Color(0xFF3F51B5);
      case Mood.confused:
        return const Color(0xFF795548);
      case Mood.proud:
        return const Color(0xFFFFD700);
      case Mood.disappointed:
        return const Color(0xFF757575);
      case Mood.content:
        return const Color(0xFF66BB6A);
      case Mood.inspired:
        return const Color(0xFFAB47BC);
      default:
        return Colors.grey;
    }
  }

  IconData _getMoodIcon(Mood mood) {
    switch (mood) {
      case Mood.happy:
        return Icons.sentiment_very_satisfied;
      case Mood.sad:
        return Icons.sentiment_very_dissatisfied;
      case Mood.neutral:
        return Icons.sentiment_neutral;
      case Mood.excited:
        return Icons.celebration;
      case Mood.calm:
        return Icons.self_improvement;
      case Mood.anxious:
        return Icons.psychology_alt;
      case Mood.grateful:
        return Icons.volunteer_activism;
      case Mood.angry:
        return Icons.sentiment_dissatisfied;
      case Mood.loved:
        return Icons.favorite;
      case Mood.peaceful:
        return Icons.spa;
      case Mood.stressed:
        return Icons.flash_on;
      case Mood.energetic:
        return Icons.bolt;
      case Mood.tired:
        return Icons.bedtime;
      case Mood.hopeful:
        return Icons.wb_sunny;
      case Mood.lonely:
        return Icons.person_outline;
      case Mood.confused:
        return Icons.help_outline;
      case Mood.proud:
        return Icons.military_tech;
      case Mood.disappointed:
        return Icons.sentiment_dissatisfied_outlined;
      case Mood.content:
        return Icons.check_circle_outline;
      case Mood.inspired:
        return Icons.auto_awesome;
      default:
        return Icons.sentiment_neutral;
    }
  }
}
