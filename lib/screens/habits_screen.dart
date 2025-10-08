import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:samapp/models/habit.dart';
import 'package:samapp/services/habit_service.dart';
import 'package:samapp/screens/add_edit_habit_screen.dart';
import 'package:samapp/widgets/empty_state.dart';
import 'package:samapp/screens/habit_details_screen.dart';
import 'package:samapp/screens/habit_streak_screen.dart';
import 'package:samapp/services/habit_streak_service.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}


class _HabitsScreenState extends State<HabitsScreen> with SingleTickerProviderStateMixin {
  final HabitService _habitService = HabitService();
  final HabitStreakService _streakService = HabitStreakService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Habits'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Habit>('habits').listenable(),
        builder: (context, Box<Habit> box, _) {
          List<Habit> habits = box.values.toList().cast<Habit>();


          if (habits.isEmpty) {
            return EmptyStates.noHabits(
              context,
              onAdd: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddEditHabitScreen(),
                  ),
                );
              },
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return Dismissible(
                key: Key(habit.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  _habitService.deleteHabit(habit.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${habit.name} deleted')),
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
                child: _buildHabitCard(context, habit),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'habits_fab',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditHabitScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, Habit habit) {
    final isWeekly = habit.frequency == HabitFrequency.timesPerWeek;
    final streak = isWeekly ? _streakService.getCurrentWeeklyStreak(habit) : _habitService.calculateStreak(habit);
    
    Color habitColor;
    switch (habit.frequency) {
      case HabitFrequency.daily:
        habitColor = Colors.blueGrey[700]!;
        break;
      case HabitFrequency.specificDays:
        habitColor = Colors.indigo[400]!;
        break;
      case HabitFrequency.timesPerWeek:
        habitColor = Colors.teal[600]!;
        break;
    }


    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HabitDetailsScreen(habit: habit),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            left: BorderSide(color: habitColor, width: 5),
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: habitColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.repeat,
                        color: habitColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text(
                                '🔥',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$streak ${isWeekly ? 'week' : 'day'}${streak == 1 ? '' : 's'} streak',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildCompletionControl(habit, habitColor),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildCompletionStats(habit, habitColor),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.insights, size: 18),
                      label: const Text('Details'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HabitStreakScreen(habit: habit),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
      ),
    );
  }

  Widget _buildCompletionStats(Habit habit, Color habitColor) {
    if (habit.frequency == HabitFrequency.specificDays) {
      final weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      final targetDays = habit.specificWeekdays ?? [];

      return Row(
        children: List.generate(7, (index) {
          final dayIndex = index + 1;
          final isTargetDay = targetDays.contains(dayIndex);
          if (!isTargetDay) return const SizedBox.shrink();

          final today = DateTime.now();
          final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
          final dateForDay = startOfWeek.add(Duration(days: index));

          final isCompleted = habit.completionDates.any((d) =>
              d.year == dateForDay.year &&
              d.month == dateForDay.month &&
              d.day == dateForDay.day);

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted ? habitColor.withOpacity(0.8) : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                weekDays[index],
                style: TextStyle(
                  fontSize: 10,
                  color: isCompleted ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      );
    }
    // For other habit types, return an empty container.
    return const SizedBox.shrink();
  }

  Widget _buildCompletionControl(Habit habit, Color habitColor) {
    switch (habit.frequency) {
      case HabitFrequency.daily:
      case HabitFrequency.specificDays:
        final isCompletedToday = habit.completionDates.any((date) =>
            date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day);
        return IconButton(
          icon: Icon(
            isCompletedToday ? Icons.check_circle : Icons.check_circle_outline,
            color: isCompletedToday ? Colors.green : Colors.grey,
            size: 32,
          ),
          onPressed: () {
            if (_habitService.isHabitDueToday(habit)) {
              _habitService.toggleHabitCompletion(habit);
            }
          },
        );
      case HabitFrequency.timesPerWeek:
        final completions = _habitService.getCompletionsThisWeek(habit);
        final target = habit.weeklyTarget ?? 1;
        return InkWell(
          onTap: () => _habitService.toggleHabitCompletion(habit),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: completions >= target ? Colors.green.withOpacity(0.1) : habitColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: completions >= target ? Colors.green : habitColor, width: 1.5),
            ),
            child: Text(
              '$completions / $target',
              style: TextStyle(
                color: completions >= target ? Colors.green : habitColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
    }
  }

}
