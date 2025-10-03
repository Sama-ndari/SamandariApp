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

class _HabitsScreenState extends State<HabitsScreen> {
  final HabitService _habitService = HabitService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Habit>('habits').listenable(),
        builder: (context, Box<Habit> box, _) {
          final habits = box.values.toList().cast<Habit>();
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
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final streak = _habitService.calculateStreak(habit);
              final isCompletedToday = habit.completionDates.contains(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

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
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                leading: Icon(Icons.repeat, color: Color(habit.color)),
                title: Text(habit.name),
                subtitle: Text('Streak: $streak day${streak == 1 ? '' : 's'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Insights button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.insights, size: 24),
                        color: Colors.blue,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => HabitStreakScreen(habit: habit),
                            ),
                          );
                        },
                        tooltip: 'View Streak Details',
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Completion button
                    IconButton(
                      icon: Icon(
                        isCompletedToday ? Icons.check_circle : Icons.check_circle_outline,
                        color: isCompletedToday ? Colors.green : null,
                        size: 28,
                      ),
                      onPressed: () {
                        _habitService.toggleHabitCompletion(habit);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HabitDetailsScreen(habit: habit),
                    ),
                  );
                },
              ),);
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
}
