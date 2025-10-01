import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:samapp/models/task.dart';
import 'package:samapp/models/expense.dart';
import 'package:samapp/models/water_intake.dart';
import 'package:samapp/models/habit.dart';
import 'package:samapp/models/goal.dart';
import 'package:samapp/screens/add_edit_task_screen.dart';
import 'package:samapp/screens/add_edit_expense_screen.dart';
import 'package:samapp/screens/add_edit_note_screen.dart';
import 'package:samapp/screens/pomodoro_screen.dart';
import 'package:samapp/widgets/suggestions_widget.dart';
import 'package:samapp/widgets/animated_transitions.dart';
import 'package:intl/intl.dart';
import 'package:samapp/utils/money_formatter.dart';
import 'package:samapp/main.dart';
import 'dart:math';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void> _refreshDashboard() async {
    // Simulate refresh delay
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.apps),
            tooltip: 'All Features',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MainScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and greeting
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick Actions with animations
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ScaleIn(
                  delay: const Duration(milliseconds: 100),
                  child: _buildQuickAction(
                    context,
                    icon: Icons.add_task,
                    label: 'Task',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddEditTaskScreen(),
                        ),
                      );
                    },
                  ),
                ),
                ScaleIn(
                  delay: const Duration(milliseconds: 200),
                  child: _buildQuickAction(
                    context,
                    icon: Icons.attach_money,
                    label: 'Expense',
                    color: Colors.green,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddEditExpenseScreen(),
                        ),
                      );
                    },
                  ),
                ),
                ScaleIn(
                  delay: const Duration(milliseconds: 300),
                  child: _buildQuickAction(
                    context,
                    icon: Icons.note_add,
                    label: 'Note',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddEditNoteScreen(),
                        ),
                      );
                    },
                  ),
                ),
                ScaleIn(
                  delay: const Duration(milliseconds: 400),
                  child: _buildQuickAction(
                    context,
                    icon: Icons.timer,
                    label: 'Focus',
                    color: Colors.red,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PomodoroScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Smart Suggestions
            const SuggestionsWidget(),
            const SizedBox(height: 24),
            
            // Quick stats grid
            Row(
              children: [
                Expanded(child: _buildTasksOverview()),
                const SizedBox(width: 12),
                Expanded(child: _buildWaterIntakeOverview()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildExpensesOverview()),
                const SizedBox(width: 12),
                Expanded(child: _buildHabitsOverview()),
              ],
            ),
            const SizedBox(height: 12),
            _buildGoalsOverview(),
          ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    final names = ['StarK', 'Sam', 'Samandari'];
    final random = Random();
    final name = names[random.nextInt(names.length)];
    
    if (hour < 12) return 'Good Morning, $name';
    if (hour < 17) return 'Good Afternoon, $name';
    return 'Good Evening, $name';
  }

  Widget _buildTasksOverview() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Task>('tasks').listenable(),
      builder: (context, Box<Task> box, _) {
        final tasks = box.values.toList().cast<Task>();
        final todayTasks = tasks.where((task) {
          final today = DateTime.now();
          return task.dueDate.year == today.year &&
              task.dueDate.month == today.month &&
              task.dueDate.day == today.day;
        }).toList();
        final completedToday = todayTasks.where((t) => t.isCompleted).length;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.blue, size: 32),
                const SizedBox(height: 12),
                Text(
                  'Tasks',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedToday/${todayTasks.length}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                if (todayTasks.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: completedToday / todayTasks.length,
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      minHeight: 6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaterIntakeOverview() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<WaterIntake>('water_intake').listenable(),
      builder: (context, Box<WaterIntake> box, _) {
        // Get today's water intake
        final today = DateTime.now();
        WaterIntake? todayIntake;
        
        for (var intake in box.values) {
          if (intake.date.year == today.year &&
              intake.date.month == today.month &&
              intake.date.day == today.day) {
            todayIntake = intake;
            break;
          }
        }
        
        final currentAmount = todayIntake?.amount ?? 0;
        const goal = 2000; // 2000 ml daily goal

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.local_drink, color: Colors.cyan, size: 32),
                const SizedBox(height: 12),
                Text(
                  'Water',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  '$currentAmount ml',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'of $goal ml',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (currentAmount / goal).clamp(0.0, 1.0),
                    backgroundColor: Colors.cyan.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpensesOverview() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Expense>('expenses').listenable(),
      builder: (context, Box<Expense> box, _) {
        final expenses = box.values.toList().cast<Expense>();
        final today = DateTime.now();
        final todayExpenses = expenses.where((expense) {
          return expense.date.year == today.year &&
              expense.date.month == today.month &&
              expense.date.day == today.day;
        }).toList();
        final totalToday = todayExpenses.fold<double>(0, (sum, e) => sum + e.amount);

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.attach_money, color: Colors.green, size: 32),
                const SizedBox(height: 12),
                Text(
                  'Expenses',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  formatMoney(totalToday).split(' ')[0], // Show only the number
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'FBu',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHabitsOverview() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Habit>('habits').listenable(),
      builder: (context, Box<Habit> box, _) {
        final habits = box.values.toList().cast<Habit>();
        final today = DateTime.now();
        final completedToday = habits.where((habit) {
          return habit.completionDates.any((date) =>
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day);
        }).length;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.repeat, color: Colors.orange, size: 32),
                const SizedBox(height: 12),
                Text(
                  'Habits',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedToday/${habits.length}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                if (habits.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: completedToday / habits.length,
                      backgroundColor: Colors.orange.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                      minHeight: 6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalsOverview() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Goal>('goals').listenable(),
      builder: (context, Box<Goal> box, _) {
        final goals = box.values.toList().cast<Goal>();
        final activeGoals = goals.where((g) => !g.isCompleted).length;
        final completedGoals = goals.where((g) => g.isCompleted).length;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.flag, color: Colors.purple, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Goals',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$activeGoals Active',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$completedGoals Done',
                    style: const TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
