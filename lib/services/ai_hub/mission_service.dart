import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:samapp/data/missions.dart';
import 'package:samapp/services/logging_service.dart';
import 'package:samapp/widgets/in_app_notification.dart';
import 'package:hive/hive.dart';
import 'package:samapp/models/task.dart';
import 'package:samapp/services/navigation_service.dart';
import 'package:uuid/uuid.dart';

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

class MissionService {
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

  void showMissionCategories(BuildContext context) {
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
                  Navigator.of(dialogContext).pop();
                  _showRandomMission(screenContext, category);
                },
                borderRadius: BorderRadius.circular(16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: category.color.withValues(alpha: 0.1),
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

  Future<void> _acceptMissionAsTask(BuildContext context, String missionContent) async {
    // Use the mission dialog's context to show the loading spinner over it.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
      ),
    );

    try {
      final prompt = 'Create a very short (3–4 words) task title for the following mission: "$missionContent". Respond ONLY with the task title — no explanations, no punctuation, nothing else.';

      final url = Uri.parse(dotenv.env['CREATIVE_MUSE_API_URL']!);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final title = jsonDecode(response.body)['muse'].replaceAll('"', '');
        final taskBox = Hive.box<Task>('tasks');
        final now = DateTime.now();
        final newTask = Task()
          ..id = const Uuid().v4()
          ..title = title
          ..description = missionContent
          ..isCompleted = false
          ..createdDate = now
          ..type = TaskType.oneTime
          ..priority = Priority.medium // This is the critical fix
          ..assignedDate = now // This is the critical fix
          ..dueDate = DateTime(now.year, now.month, now.day, 23, 59, 59); // This is the critical fix

        await taskBox.add(newTask);

        // Use the stable navigator context for the SnackBar
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
          const SnackBar(
            content: Text('Mission added to your tasks!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw Exception('Failed to generate title');
      }
    } catch (e) {
      ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Error: Could not create task. $e')),
      );
    } finally {
      // THIS IS THE FIX: Use the stable GlobalKey context to pop the dialogs.
      final navigator = Navigator.of(NavigationService.navigatorKey.currentContext!);
      if (navigator.canPop()) navigator.pop(); // Pop the loading spinner
      if (navigator.canPop()) navigator.pop(); // Pop the mission dialog
    }
  }

  Future<void> _showRandomMission(BuildContext context, MissionCategory category) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    String? mission;
    bool isFromApi = false;

    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        final prompt = 'Write one short, playful mission under 15 words for the category \'${category.name}\'. It should feel motivating, specific, and fun to complete.';
        final url = Uri.parse(dotenv.env['CREATIVE_MUSE_API_URL']!);
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'prompt': prompt}),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          mission = jsonDecode(response.body)['muse'];
          isFromApi = true;
        }
      }
    } catch (e) {
      AppLogger.error('Error fetching dynamic mission', e);
    } finally {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      mission ??= _getStaticMission(category);

      if (context.mounted) {
        _showMissionDialog(context, category, mission, isFromApi);
      }
    }
  }

  void _showMissionDialog(BuildContext context, MissionCategory category, String mission, bool isFromApi) {
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
          if (isFromApi)
            TextButton(
              onPressed: () {
                // DO NOT pop here. Let the async method handle it.
                _acceptMissionAsTask(context, mission);
              },
              child: const Text('Accept as Task'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              isFromApi ? 'Done' : 'Awesome!',
              style: TextStyle(color: category.color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _getStaticMission(MissionCategory category) {
    if (category.missions.isEmpty) return "No missions available for this category.";
    final random = Random();
    return category.missions[random.nextInt(category.missions.length)];
  }
}
