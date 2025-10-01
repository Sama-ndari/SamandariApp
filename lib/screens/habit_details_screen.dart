import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:samapp/models/habit.dart';
import 'package:samapp/screens/add_edit_habit_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class HabitDetailsScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailsScreen({super.key, required this.habit});

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Habit>('habits').listenable(),
      builder: (context, Box<Habit> box, _) {
        // Get the latest version of the habit
        Habit habit;
        try {
          // Try to find the habit by ID
          habit = box.values.firstWhere(
            (h) => h.id == widget.habit.id,
            orElse: () => widget.habit,
          );
        } catch (e) {
          habit = widget.habit;
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Text(habit.name ?? 'Habit'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddEditHabitScreen(habit: habit),
                    ),
                  );
                  // Refresh will happen automatically via ValueListenableBuilder
                },
                tooltip: 'Edit Habit',
              ),
            ],
          ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${habit.description ?? "No description"}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
                          const SizedBox(height: 8),
                          Text('${habit.currentStreak}', style: Theme.of(context).textTheme.headlineMedium),
                          const Text('Current Streak'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                          const SizedBox(height: 8),
                          Text('${habit.longestStreak}', style: Theme.of(context).textTheme.headlineMedium),
                          const Text('Best Streak'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (habit.notes?.isNotEmpty ?? false) ...[
              Text('Notes', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(habit.notes ?? 'No notes'),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text('Completion History', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TableCalendar(
              firstDay: habit.createdAt ?? DateTime.now(),
              lastDay: DateTime.now(),
              focusedDay: DateTime.now(),
              calendarFormat: CalendarFormat.month,
              eventLoader: (day) {
                return habit.completionDates.where((date) => isSameDay(date, day)).toList();
              },
            ),
          ],
        ),
      ),
        );
      },
    );
  }
}
