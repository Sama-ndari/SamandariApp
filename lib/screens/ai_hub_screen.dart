import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io'; // For SocketException
import 'dart:async'; // For TimeoutException
import 'package:samapp/data/missions.dart';
import 'package:samapp/screens/legacy_capsule_list_screen.dart';
import 'package:samapp/services/dynamic_challenge_service.dart';
import 'package:hive/hive.dart';
import 'package:samapp/models/note.dart';
import 'package:samapp/models/journal_entry.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AiHubScreen extends StatefulWidget {
  const AiHubScreen({super.key});

  @override
  State<AiHubScreen> createState() => _AiHubScreenState();
}

class MissionCategory {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> missions;

  MissionCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.missions,
  });
}

class _AiHubScreenState extends State<AiHubScreen> {
  final List<MissionCategory> _missionCategories = [
    MissionCategory(
      name: 'Productivity',
      icon: Icons.rocket_launch,
      color: Colors.blue,
      missions: productivityMissions,
    ),
    MissionCategory(
      name: 'SoulSync',
      icon: Icons.self_improvement,
      color: Colors.purple,
      missions: soulSyncMissions,
    ),
    MissionCategory(
      name: 'Finance',
      icon: Icons.monetization_on,
      color: Colors.green,
      missions: financeMissions,
    ),
    MissionCategory(
      name: 'Creativity',
      icon: Icons.palette,
      color: Colors.orange,
      missions: creativityMissions,
    ),
    MissionCategory(
      name: 'Courage',
      icon: Icons.security,
      color: Colors.red,
      missions: courageMissions,
    ),
    MissionCategory(
      name: 'Social',
      icon: Icons.people,
      color: Colors.teal,
      missions: eqAndSocialMissions,
    ),
  ];

  void _showMissionCategories(BuildContext context) {
    // Capture the correct context before showing the dialog.
    final screenContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose a Mission Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: _missionCategories.length,
            itemBuilder: (context, index) {
              final category = _missionCategories[index];
              return InkWell(
                onTap: () {
                  Navigator.of(dialogContext).pop(); // Close category dialog
                  // Use the stable screenContext to show the next dialog.
                  _showRandomMission(screenContext, category);
                },
                borderRadius: BorderRadius.circular(16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: category.color.withOpacity(0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(category.icon, size: 40, color: category.color),
                      const SizedBox(height: 12),
                      Text(
                        category.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: category.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showRandomMission(BuildContext context, MissionCategory category) async {
    // Show a loading dialog while fetching the mission
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    String? mission;

    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        final prompt = 'Write one short, playful mission under 15 words for the category \'${category.name}\'. It should feel motivating, specific, and fun to complete.';
        final url = Uri.parse('https://creative-muse-backend.vercel.app/api/get-muse');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'prompt': prompt}),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          mission = jsonDecode(response.body)['muse'];
        }
      }
    } catch (e) {
      // Log the error for debugging, but otherwise fail silently.
      print('Error fetching dynamic mission: $e');
    } finally {
      // Ensure the loading dialog is always closed.
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // If the mission is still null (due to offline or error), get a static one.
      mission ??= _getStaticMission(category);

      // Show the final mission dialog.
      _showMissionDialog(context, category, mission!);
    }

  }

  void _showMissionDialog(BuildContext context, MissionCategory category, String mission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(category.icon, color: category.color),
            const SizedBox(width: 12),
            Text('${category.name} Mission'),
          ],
        ),
        content: Text(
          mission,
          style: const TextStyle(fontSize: 18, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Awesome!',
              style: TextStyle(color: category.color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get a mission from the static offline list
  String _getStaticMission(MissionCategory category) {
    if (category.missions.isEmpty) return "No missions available for this category.";
    final random = Random();
    return category.missions[random.nextInt(category.missions.length)];
  }

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

  Future<void> _getCreativeMuse(BuildContext context) async {
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final recentContext = _getRecentContext();
      final prompt = 'Generate a single, short, and profound creative idea. It could be a poetic thought, a melody idea, or a visual prompt. Make it intriguing and concise. For inspiration, here is some recent context from the user\'s private notes (if empty, just be creative): "$recentContext"';

      final url = Uri.parse('https://creative-muse-backend.vercel.app/api/get-muse');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      ).timeout(const Duration(seconds: 20));

      // Close the loading dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final muse = data['muse'];

        // Show the result dialog
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
                  _saveMuseAsNote(muse);
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
      // Close the loading dialog
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

      // Show an error dialog
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

  void _saveMuseAsNote(String museContent) {
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

  Future<void> _getDynamicChallenge(BuildContext context) async {
    final challengeService = DynamicChallengeService();
    final analysisResult = challengeService.findChallengeArea();

    if (analysisResult.category == 'Success') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(children: [Icon(analysisResult.icon, color: Colors.green), const SizedBox(width: 12), const Text('Great Job!')]),
          content: Text(analysisResult.description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final random = Random();
      final promptTemplates = [
        'Generate a single, fun, and simple one-day challenge that is easy to start. The tone should be encouraging, not demanding. The challenge is for a user where: ${analysisResult.description}',
        'Based on the following situation, what is one small, positive action the user could take today? Situation: ${analysisResult.description}',
        'Create a fun, bite-sized mission for someone in this situation: ${analysisResult.description}. Make it sound exciting and achievable in a single day.',
        'I\'m a user who is currently facing this: "${analysisResult.description}". Suggest a simple, one-day activity to help me get back on track. Be creative and supportive.',
      ];
      final prompt = promptTemplates[random.nextInt(promptTemplates.length)];

      // --- DEBUG PRINTS ---
      print('[Dynamic Challenge] Analysis Result: ${analysisResult.description}');
      print('[Dynamic Challenge] Generated Prompt: $prompt');
      // --- END DEBUG PRINTS ---

      final url = Uri.parse('https://creative-muse-backend.vercel.app/api/get-muse');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      ).timeout(const Duration(seconds: 20));

      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final challenge = data['muse'];

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(analysisResult.icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('A Challenge for Your ${analysisResult.category}'),
                ),
              ],
            ),
            content: Text(
              challenge,
              style: const TextStyle(fontSize: 18, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Decline'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Challenge accepted! (Functionality coming soon)')),
                  );
                },
                child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed to load challenge. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      String title = 'An Error Occurred';
      String content = 'Could not fetch a dynamic challenge. Please try again later.';

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
          actions: [ TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')) ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Hub'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const _FeatureCard(
            icon: Icons.mic,
            title: 'Voice Assistant / Chatbot',
            description: 'Your AI buddy that talks with your stored data.',
          ),
          const _FeatureCard(
            icon: Icons.psychology,
            title: 'AI Life Coach / Therapist',
            description: 'Trained on your own journal data to reflect your patterns back to you.',
          ),
          _FeatureCard(
            icon: Icons.explore,
            title: 'Random Life Missions',
            description: 'Small daily adventures to spice up your life.',
            onTap: () => _showMissionCategories(context),
          ),
          _FeatureCard(
            icon: Icons.lightbulb,
            title: 'Creative Muse Generator',
            description: 'AI-powered ideas for your next creative spark.',
            onTap: () => _getCreativeMuse(context),
          ),
          _FeatureCard(
            icon: Icons.track_changes,
            title: 'Dynamic Challenges',
            description: 'Personalized missions to balance your life stats.',
            onTap: () => _getDynamicChallenge(context),
          ),
          _FeatureCard(
            icon: Icons.watch_later,
            title: 'Legacy Capsule',
            description: 'Digital time capsules for your future self or loved ones.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LegacyCapsuleListScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title),
        subtitle: Text(description),
        onTap: onTap ??
            () {
              // Default behavior for other cards
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title coming soon!')),
              );
            },
      ),
    );
  }
}
