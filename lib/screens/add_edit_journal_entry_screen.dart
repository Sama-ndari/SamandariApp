import 'package:flutter/material.dart';
import 'package:samapp/models/journal_entry.dart';
import 'package:samapp/services/journal_service.dart';

class AddEditJournalEntryScreen extends StatefulWidget {
  final JournalEntry? entry;

  const AddEditJournalEntryScreen({super.key, this.entry});

  @override
  State<AddEditJournalEntryScreen> createState() => _AddEditJournalEntryScreenState();
}

class _AddEditJournalEntryScreenState extends State<AddEditJournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _journalService = JournalService();

  late String _content;
  late Mood _mood;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _content = widget.entry?.content ?? '';
    _mood = widget.entry?.mood ?? Mood.neutral;
    _tags = widget.entry?.tags ?? [];
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newEntry = JournalEntry()
        ..id = widget.entry?.id ?? ''
        ..content = _content
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
              TextFormField(
                initialValue: _content,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some content';
                  }
                  return null;
                },
                onSaved: (value) => _content = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Mood>(
                value: _mood,
                decoration: const InputDecoration(labelText: 'Mood'),
                items: Mood.values.map((mood) {
                  return DropdownMenuItem(
                    value: mood,
                    child: Text(mood.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _mood = value!;
                  });
                },
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
}
