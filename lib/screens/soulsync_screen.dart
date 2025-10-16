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
          // Sort by date, most recent first
          entries.sort((a, b) => b.date.compareTo(a.date));
          
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_stories, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Start Your Soul Journey',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to record your first entry',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Dismissible(
                key: Key(entry.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  _journalService.deleteJournalEntry(entry.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Journal entry deleted')),
                  );
                },
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: _buildJournalCard(context, entry),
              );
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

  Widget _buildJournalCard(BuildContext context, JournalEntry entry) {
    final moodColor = _getMoodColor(entry.mood);
    final moodName = entry.mood.toString().split('.').last;
    final formattedMood = moodName[0].toUpperCase() + moodName.substring(1);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditJournalEntryScreen(entry: entry),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(color: moodColor, width: 5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: moodColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getMoodIcon(entry.mood),
                        color: moodColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedMood,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: moodColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('EEEE, MMM d, y · h:mm a').format(entry.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  entry.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                if (entry.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: entry.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
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
        return Colors.grey.shade400;
      case Mood.excited:
        return Colors.orange;
      case Mood.calm:
        return Colors.teal;
      case Mood.anxious:
        return Colors.deepPurple;
      case Mood.grateful:
        return Colors.pink;
      case Mood.angry:
        return Colors.red;
      case Mood.loved:
        return Colors.pinkAccent;
      case Mood.peaceful:
        return Colors.cyan;
      case Mood.stressed:
        return Colors.deepOrange;
      case Mood.energetic:
        return Colors.amber;
      case Mood.tired:
        return Colors.blueGrey;
      case Mood.hopeful:
        return Colors.lightGreen;
      case Mood.lonely:
        return Colors.indigo;
      case Mood.confused:
        return Colors.brown;
      case Mood.proud:
        return Colors.yellow.shade800;
      case Mood.disappointed:
        return Colors.blueGrey.shade600;
      case Mood.content:
        return Colors.lightBlue;
      case Mood.inspired:
        return Colors.purpleAccent;
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
