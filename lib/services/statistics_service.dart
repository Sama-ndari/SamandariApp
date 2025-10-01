import 'package:hive/hive.dart';
import 'package:samapp/models/task.dart';
import 'package:samapp/models/expense.dart';
import 'package:samapp/models/habit.dart';
import 'package:samapp/models/goal.dart';
import 'package:samapp/models/note.dart';
import 'package:samapp/models/water_intake.dart';
import 'package:samapp/models/app_statistics.dart';
import 'package:uuid/uuid.dart';

class StatisticsService {
  final Box<Task> _taskBox = Hive.box<Task>('tasks');
  final Box<Expense> _expenseBox = Hive.box<Expense>('expenses');
  final Box<Habit> _habitBox = Hive.box<Habit>('habits');
  final Box<Goal> _goalBox = Hive.box<Goal>('goals');
  final Box<Note> _noteBox = Hive.box<Note>('notes');
  final Box<WaterIntake> _waterBox = Hive.box<WaterIntake>('water_intake');
  final Box<AppStatistics> _statsBox = Hive.box<AppStatistics>('statistics');
  final Uuid _uuid = const Uuid();

  // Get task completion rate for a date range
  Map<String, dynamic> getTaskStats(DateTime start, DateTime end) {
    final tasks = _taskBox.values.where((task) {
      return task.createdDate.isAfter(start) && task.createdDate.isBefore(end);
    }).toList();

    final completed = tasks.where((t) => t.isCompleted).length;
    final total = tasks.length;
    final rate = total > 0 ? (completed / total * 100).toStringAsFixed(1) : '0';

    return {
      'total': total,
      'completed': completed,
      'pending': total - completed,
      'completionRate': rate,
    };
  }

  // Get expense breakdown by category
  Map<ExpenseCategory, double> getExpensesByCategory(DateTime start, DateTime end) {
    final expenses = _expenseBox.values.where((expense) {
      return expense.date.isAfter(start) && expense.date.isBefore(end);
    }).toList();

    Map<ExpenseCategory, double> breakdown = {};
    for (var category in ExpenseCategory.values) {
      breakdown[category] = 0;
    }

    for (var expense in expenses) {
      breakdown[expense.category] = (breakdown[expense.category] ?? 0) + expense.amount;
    }

    return breakdown;
  }

  // Get total expenses for period
  double getTotalExpenses(DateTime start, DateTime end) {
    return _expenseBox.values
        .where((expense) => expense.date.isAfter(start) && expense.date.isBefore(end))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get habit completion stats
  Map<String, dynamic> getHabitStats(DateTime start, DateTime end) {
    final habits = _habitBox.values.toList();
    int totalCompletions = 0;

    for (var habit in habits) {
      totalCompletions += habit.completionDates.where((date) {
        return date.isAfter(start) && date.isBefore(end);
      }).length;
    }

    return {
      'totalHabits': habits.length,
      'totalCompletions': totalCompletions,
      'averagePerDay': totalCompletions / (end.difference(start).inDays + 1),
    };
  }

  // Get weekly stats (last 7 days)
  Map<String, dynamic> getWeeklyStats() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    return {
      'tasks': getTaskStats(weekAgo, now),
      'expenses': getTotalExpenses(weekAgo, now),
      'habits': getHabitStats(weekAgo, now),
    };
  }

  // Get monthly stats
  Map<String, dynamic> getMonthlyStats() {
    final now = DateTime.now();
    final monthAgo = DateTime(now.year, now.month - 1, now.day);
    
    return {
      'tasks': getTaskStats(monthAgo, now),
      'expenses': getTotalExpenses(monthAgo, now),
      'expensesByCategory': getExpensesByCategory(monthAgo, now),
      'habits': getHabitStats(monthAgo, now),
    };
  }

  // Save daily statistics
  Future<void> saveDailyStats() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final todayTasks = _taskBox.values.where((task) {
      return task.completedDate != null &&
          task.completedDate!.isAfter(today) &&
          task.completedDate!.isBefore(tomorrow);
    }).length;

    final todayHabits = _habitBox.values.where((habit) {
      return habit.completionDates.any((date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day);
    }).length;

    final todayExpenses = _expenseBox.values
        .where((expense) =>
            expense.date.year == today.year &&
            expense.date.month == today.month &&
            expense.date.day == today.day)
        .fold(0.0, (sum, expense) => sum + expense.amount);

    final todayNotes = _noteBox.values.where((note) {
      return note.createdAt.year == today.year &&
          note.createdAt.month == today.month &&
          note.createdAt.day == today.day;
    }).length;

    // Count goals completed today (we don't have completedAt, so just count completed goals)
    final todayGoals = 0; // TODO: Add completedAt field to Goal model in future

    WaterIntake? todayWater;
    for (var water in _waterBox.values) {
      if (water.date.year == today.year &&
          water.date.month == today.month &&
          water.date.day == today.day) {
        todayWater = water;
        break;
      }
    }

    final stats = AppStatistics()
      ..id = _uuid.v4()
      ..date = today
      ..tasksCompleted = todayTasks
      ..habitsCompleted = todayHabits
      ..totalExpenses = todayExpenses
      ..waterGlasses = todayWater?.amount ?? 0
      ..notesCreated = todayNotes
      ..goalsAchieved = todayGoals
      ..createdAt = now;

    await _statsBox.put(stats.id, stats);
  }

  // Get stats for last N days
  List<AppStatistics> getLastNDaysStats(int days) {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: days));

    return _statsBox.values
        .where((stat) => stat.date.isAfter(cutoff))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
