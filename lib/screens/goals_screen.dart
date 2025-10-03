import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:samapp/models/goal.dart';
import 'package:samapp/services/goal_service.dart';
import 'package:samapp/screens/add_edit_goal_screen.dart';
import 'package:samapp/widgets/empty_state.dart';
import 'package:intl/intl.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final GoalService _goalService = GoalService();

  Color _getGoalColor(GoalType type) {
    switch (type) {
      case GoalType.savings:
        return Colors.green;
      case GoalType.fitness:
        return Colors.orange;
      case GoalType.learning:
        return Colors.blue;
      case GoalType.personal:
        return Colors.purple;
      case GoalType.other:
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Goal>('goals').listenable(),
        builder: (context, Box<Goal> box, _) {
          final goals = box.values.toList().cast<Goal>();
          
          if (goals.isEmpty) {
            return EmptyStates.noGoals(
              context,
              onAdd: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddEditGoalScreen(),
                  ),
                );
              },
            );
          }

          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return Dismissible(
                key: Key(goal.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  _goalService.deleteGoal(goal.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${goal.title} deleted')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getGoalColor(goal.type),
                      child: Icon(
                        goal.isCompleted ? Icons.check : Icons.flag,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      goal.title,
                      style: TextStyle(
                        decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal.usesPercentage 
                                        ? '${goal.formattedCurrent} of ${goal.formattedTarget}'
                                        : '${goal.formattedCurrent} ${goal.displayUnit} of ${goal.formattedTarget} ${goal.displayUnit}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  LinearProgressIndicator(
                                    value: goal.progressPercentage / 100,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(_getGoalColor(goal.type)),
                                    minHeight: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${goal.progressPercentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _getGoalColor(goal.type),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              'Due: ${DateFormat('MMM d, y').format(goal.deadline)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: goal.isOverdue ? Colors.red : Colors.grey[600],
                                fontWeight: goal.isOverdue ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: goal.isCompleted
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddEditGoalScreen(goal: goal),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'goals_fab',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditGoalScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
