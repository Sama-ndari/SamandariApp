import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:samapp/models/habit.dart';
import 'package:samapp/screens/add_edit_habit_screen.dart';
import 'package:samapp/screens/habit_statistics_screen.dart';
import 'package:samapp/services/habit_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:samapp/services/habit_streak_service.dart';
import 'package:intl/intl.dart';

class HabitDetailsScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailsScreen({super.key, required this.habit});

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  final HabitService _habitService = HabitService();
  final HabitStreakService _streakService = HabitStreakService();
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
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      child: Row(
                        children: [
                          Icon(Icons.local_fire_department, color: Colors.orange, size: 36),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.frequency == HabitFrequency.timesPerWeek 
                                  ? '${_streakService.getCurrentWeeklyStreak(habit)}'
                                  : '${habit.currentStreak}', 
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                habit.frequency == HabitFrequency.timesPerWeek ? 'Weekly Streak' : 'Current Streak',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      child: Row(
                        children: [
                          Icon(Icons.emoji_events, color: Colors.amber, size: 36),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.frequency == HabitFrequency.timesPerWeek
                                  ? '${_streakService.getLongestWeeklyStreak(habit)}'
                                  : '${habit.longestStreak}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text('Best Streak', style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
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
            if (habit.frequency == HabitFrequency.timesPerWeek)
              _buildWeeklySuccessGrid(habit)
            else if (habit.frequency == HabitFrequency.specificDays)
              _buildSpecificDaysCalendar(habit)
            else
              _buildDailyCalendar(habit),
          ],
        ),
        ),
      ),
        );
      },
    );
  }

  Widget _buildDailyCalendar(Habit habit) {
    return TableCalendar(
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
            // For missed days, show a faded red circle and text
            return Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(color: Colors.red.withOpacity(0.7)),
                  ),
                ),
              ),
            );
          }
          return null;
        },
      ),
    );
  }

  Widget _buildWeeklySuccessGrid(Habit habit) {
    final completionsThisWeek = _habitService.getCompletionsThisWeek(habit);
    final target = habit.weeklyTarget ?? 1;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("This Week's Progress", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red, size: 40),
                  onPressed: completionsThisWeek > 0 ? () => _habitService.removeLastCompletion(habit) : null,
                ),
                const SizedBox(width: 24),
                Text('$completionsThisWeek / $target', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(width: 24),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green, size: 40),
                  onPressed: completionsThisWeek < target ? () => _habitService.addCompletion(habit) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificDaysCalendar(Habit habit) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("This Week's Targets", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final date = startOfWeek.add(Duration(days: index));
                final isTargetDay = habit.specificWeekdays?.contains(date.weekday) ?? false;
                if (!isTargetDay) return Container(width: 40);

                final isCompleted = habit.completionDates.any((d) => isSameDay(d, date));

                return Column(
                  children: [
                    Text(weekDays[index]),
                    const SizedBox(height: 8),
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isCompleted ? Colors.green : Colors.grey,
                      size: 32,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
