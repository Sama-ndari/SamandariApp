import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:samapp/models/note.dart';
import 'package:samapp/models/journal_entry.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class _MuseTheme {
  final String name;
  final IconData icon;
  final Color color;

  _MuseTheme(this.name, this.icon, this.color);
}

class MuseService {
  String _getRecentContext() {
    final noteBox = Hive.box<Note>('notes');
    final journalBox = Hive.box<JournalEntry>('journal_entries');

    final recentNotes = noteBox.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recentJournals = journalBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));

    String context = '';
    if (recentNotes.isNotEmpty) {
      context += 'Recent Notes: ' + recentNotes.take(3).map((n) => n.title).join(', ');
    }
    if (recentJournals.isNotEmpty) {
      context += '\nRecent Journal Themes: ' + recentJournals.take(3).map((j) => j.mood.toString().split('.').last).join(', ');
    }

    return context.trim();
  }

  Future<void> getCreativeMuse(BuildContext context) async {
    final List<_MuseTheme> themes = [
      _MuseTheme('Writing Prompt', Icons.edit, Colors.blue.shade300),
      _MuseTheme('Artistic Idea', Icons.palette, Colors.purple.shade300),
      _MuseTheme('Philosophical Question', Icons.psychology, Colors.teal.shade300),
      _MuseTheme('Business Concept', Icons.work, Colors.orange.shade300),
      _MuseTheme('Developer Idea', Icons.code, Colors.green.shade300),
      _MuseTheme('Movie Concept', Icons.movie, Colors.red.shade300),
      _MuseTheme('Music Idea', Icons.music_note, Colors.pink.shade300),
      _MuseTheme('Food Recipe', Icons.restaurant, Colors.yellow.shade800),
      _MuseTheme('Trip Idea', Icons.airplanemode_active, Colors.cyan.shade300),
    ];

    final selectedTheme = await _showMuseThemeDialog(context, themes);
    if (selectedTheme == null) return; // User cancelled

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final recentContext = _getRecentContext();
      final prompt = 'Generate a single, short, and profound creative idea for the theme \'${selectedTheme.name}\'. It could be a poetic thought, a melody idea, or a visual prompt. Make it intriguing and concise. For inspiration, here is some recent context from the user\'s private notes (if empty, just be creative): "$recentContext"';

      final url = Uri.parse(dotenv.env['CREATIVE_MUSE_API_URL']!);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      ).timeout(const Duration(seconds: 20));

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final muse = data['muse'];

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.orange),
                SizedBox(width: 12),
                Text('Creative Muse'),
              ],
            ),
            content: Text(
              '"$muse"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _saveMuseAsNote(context, muse);
                },
                child: const Text('Save as Note'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Done',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed to load muse. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      String title = 'An Error Occurred';
      String content = 'Could not fetch a creative muse. Please try again later.';

      if (e is SocketException) {
        title = 'No Internet Connection';
        content = 'Please check your network connection and try again.';
      } else if (e is TimeoutException) {
        title = 'Request Timed Out';
        content = 'The server took too long to respond. Please try again later.';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<_MuseTheme?> _showMuseThemeDialog(BuildContext context, List<_MuseTheme> themes) {
    return showDialog<_MuseTheme>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose a Theme'),
          contentPadding: const EdgeInsets.all(16),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 cards per row for a better look
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.2, // Adjust aspect ratio for a pleasing card shape
              ),
              itemCount: themes.length,
              itemBuilder: (context, index) {
                final theme = themes[index];
                return Card(
                  elevation: 4,
                  color: theme.color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(theme),
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(theme.icon, size: 30, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          theme.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _saveMuseAsNote(BuildContext context, String museContent) {
    final noteBox = Hive.box<Note>('notes');
    final newNote = Note()
      ..id = const Uuid().v4()
      ..title = museContent.split(' ').take(5).join(' ') + '...'
      ..content = museContent
      ..tags = ['AI Muse']
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    noteBox.add(newNote);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Creative Muse saved to your notes!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
