import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:samapp/models/habit.dart';
import 'package:samapp/screens/add_edit_habit_screen.dart';
import 'package:samapp/screens/habit_statistics_screen.dart';
import 'package:samapp/services/habit_service.dart';
import 'package:table_calendar/table_calendar.dart';

class HabitDetailsScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailsScreen({super.key, required this.habit});

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  final HabitService _habitService = HabitService();
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
              IconButton(
                icon: const Icon(Icons.show_chart),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HabitStatisticsScreen(habit: habit),
                    ),
                  );
                },
                tooltip: 'View Statistics',
              ),
            ],
          ),
      body: SingleChildScrollView(
        child: Padding(
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
              firstDay: habit.createdAt.subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: DateTime.now(),
              calendarFormat: CalendarFormat.month,
              eventLoader: (day) {
                final dayWithoutTime = DateTime(day.year, day.month, day.day);
                return habit.completionDates
                    .where((date) => isSameDay(date, dayWithoutTime))
                    .toList();
              },
              onDaySelected: (selectedDay, focusedDay) {
                final today = DateTime.now();
                final todayWithoutTime = DateTime(today.year, today.month, today.day);
                final selectedDayWithoutTime = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

                if (isSameDay(selectedDayWithoutTime, todayWithoutTime)) {
                  _habitService.toggleHabitCompletion(habit);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("You can only complete a habit for the current day."),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  final today = DateTime.now();
                  final todayWithoutTime = DateTime(today.year, today.month, today.day);
                  final dayWithoutTime = DateTime(day.year, day.month, day.day);
                  final isCompleted = events.isNotEmpty;

                  if (isCompleted) {
                    return Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(habit.color).withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        width: 32,
                        height: 32,
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  } else if (day.isBefore(todayWithoutTime)) {
                    return Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const Icon(Icons.close, color: Colors.red, size: 32),
                        ],
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        ),
      ),
        );
      },
    );
  }
}
