import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:samapp/models/habit.dart';
import 'package:samapp/services/habit_service.dart';
import 'package:samapp/screens/add_edit_habit_screen.dart';
import 'package:samapp/widgets/empty_state.dart';
import 'package:samapp/screens/habit_details_screen.dart';
import 'package:samapp/screens/habit_streak_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

enum HabitFilter { active, archived }

class _HabitsScreenState extends State<HabitsScreen> with SingleTickerProviderStateMixin {
  final HabitService _habitService = HabitService();
  HabitFilter _currentFilter = HabitFilter.active;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SegmentedButton<HabitFilter>(
          segments: const [
            ButtonSegment(value: HabitFilter.active, label: Text('Active')),
            ButtonSegment(value: HabitFilter.archived, label: Text('Archived')),
          ],
          selected: {_currentFilter},
          onSelectionChanged: (Set<HabitFilter> newSelection) {
            setState(() {
              _currentFilter = newSelection.first;
            });
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Habit>('habits').listenable(),
        builder: (context, Box<Habit> box, _) {
          List<Habit> habits = box.values.toList().cast<Habit>();

          // Filter habits
          if (_currentFilter == HabitFilter.active) {
            habits = habits.where((h) => !h.isArchived).toList();
          } else {
            habits = habits.where((h) => h.isArchived).toList();
          }

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
    final streak = _habitService.calculateStreak(habit);
    final isCompletedToday = habit.completionDates.any((date) =>
        date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day);
    final habitColor = Color(habit.color);

    // For measurable/timed habits, we need to check if a value has been logged for today.
    // This is a placeholder. A more robust solution would store daily values.
    final isMeasurableCompleted = habit.type != HabitType.yesNo && isCompletedToday;

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
                                '$streak day${streak == 1 ? '' : 's'} streak',
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
                    Container(
                      decoration: BoxDecoration(
                        color: isCompletedToday
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: habit.type == HabitType.yesNo
                          ? _buildYesNoButton(habit, isCompletedToday)
                          : _buildMeasurableButton(context, habit, isMeasurableCompleted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildCompletionStats(habit),
                    ),
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

  Widget _buildCompletionStats(Habit habit) {
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) {
      return now.subtract(Duration(days: 6 - i));
    });

    return Row(
      children: last7Days.map((date) {
        final dateOnly = DateTime(date.year, date.month, date.day);
        final isCompleted = habit.completionDates.any((completedDate) =>
            completedDate.year == dateOnly.year &&
            completedDate.month == dateOnly.month &&
            completedDate.day == dateOnly.day);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted
                ? Color(habit.color).withOpacity(0.8)
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              date.day.toString(),
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

  Widget _buildYesNoButton(Habit habit, bool isCompleted) {
    return IconButton(
      icon: Icon(
        isCompleted ? Icons.check_circle : Icons.check_circle_outline,
        color: isCompleted ? Colors.green : Colors.grey,
        size: 32,
      ),
      onPressed: () {
        _habitService.toggleHabitCompletion(habit);
      },
    );
  }

  Widget _buildMeasurableButton(BuildContext context, Habit habit, bool isCompleted) {
    return IconButton(
      icon: Icon(
        isCompleted ? Icons.check_box : Icons.add_box_outlined,
        color: isCompleted ? Colors.green : Colors.grey,
        size: 32,
      ),
      onPressed: () {
        // For simplicity, we'll just toggle completion. A real implementation
        // would show a dialog to enter the value.
        _showEnterValueDialog(context, habit);
      },
    );
  }

  void _showEnterValueDialog(BuildContext context, Habit habit) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Log ${habit.name}'),
          content: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Value (${habit.goalUnit})'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Log'),
              onPressed: () {
                // Here you would save the value. For now, we just mark as complete.
                if (!habit.completionDates.any((d) => d.isAtSameMomentAs(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)))) {
                   _habitService.toggleHabitCompletion(habit);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
