import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:samapp/models/journal_entry.dart';
import 'package:samapp/services/journal_service.dart';
import 'package:samapp/screens/add_edit_journal_entry_screen.dart';

class SoulSyncScreen extends StatefulWidget {
  const SoulSyncScreen({super.key});

  @override
  State<SoulSyncScreen> createState() => _SoulSyncScreenState();
}

class _SoulSyncScreenState extends State<SoulSyncScreen> {
  final JournalService _journalService = JournalService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box<JournalEntry>('journal_entries').listenable(),
        builder: (context, Box<JournalEntry> box, _) {
          final entries = box.values.toList().cast<JournalEntry>();
          if (entries.isEmpty) {
            return const Center(
              child: Text('No journal entries yet!'),
            );
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Dismissible(
                key: Key(entry.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  _journalService.deleteJournalEntry(entry.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Journal entry deleted')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                leading: Icon(_getMoodIcon(entry.mood), color: _getMoodColor(entry.mood)),
                title: Text(DateFormat.yMMMd().format(entry.date)),
                subtitle: Text(entry.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddEditJournalEntryScreen(entry: entry),
                    ),
                  );
                },
              ),);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'soulsync_fab',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditJournalEntryScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getMoodColor(Mood mood) {
    switch (mood) {
      case Mood.happy:
        return Colors.green;
      case Mood.sad:
        return Colors.blue;
      case Mood.neutral:
        return Colors.grey;
      case Mood.excited:
        return Colors.orange;
      case Mood.calm:
        return Colors.teal;
      case Mood.anxious:
        return Colors.purple;
      case Mood.grateful:
        return Colors.pink;
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
        return Icons.sentiment_very_dissatisfied;
      case Mood.grateful:
        return Icons.volunteer_activism;
      default:
        return Icons.sentiment_neutral;
    }
  }
}
