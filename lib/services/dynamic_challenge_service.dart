import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:samapp/models/task.dart';
import 'package:samapp/models/habit.dart';
import 'package:samapp/models/expense.dart';
import 'package:samapp/models/water_intake.dart';

class ChallengeAnalysisResult {
  final String description;
  final String category;
  final IconData icon;

  ChallengeAnalysisResult({required this.description, required this.category, required this.icon});
}

class DynamicChallengeService {
  final List<ChallengeAnalysisResult? Function()> _analysisFunctions;

  DynamicChallengeService() : _analysisFunctions = [] {
    _analysisFunctions.addAll([
      _findOverdueTask,
      _findLowHabitStreak,
      _findHighSpendingArea,
      _findLowWaterIntake,
    ]);
  }

  /// Randomly selects an analysis function and returns a challenge area.
  ChallengeAnalysisResult findChallengeArea() {
    final random = Random();
    final shuffledFunctions = _analysisFunctions.toList()..shuffle(random);

    for (var analysisFunc in shuffledFunctions) {
      final result = analysisFunc();
      if (result != null) {
        return result; // Return the first valid challenge area found.
      }
    }

    return ChallengeAnalysisResult(description: 'All caught up! Great job.', category: 'Success', icon: Icons.check_circle);
  }

  /// Finds the oldest overdue, uncompleted task.
  ChallengeAnalysisResult? _findOverdueTask() {
    final taskBox = Hive.box<Task>('tasks');
    final now = DateTime.now();
    final overdueTasks = taskBox.values.where((t) => !t.isCompleted && t.dueDate.isBefore(now)).toList();

    if (overdueTasks.isEmpty) return null;

    overdueTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final oldestTask = overdueTasks.first;
    return ChallengeAnalysisResult(
      description: 'The user has an overdue task named \"${oldestTask.title}\".',
      category: 'Tasks',
      icon: Icons.check_circle_outline,
    );
  }

  ChallengeAnalysisResult? _findLowHabitStreak() {
    final habitBox = Hive.box<Habit>('habits');
    if (habitBox.values.isEmpty) return null;

    Habit? leastCompletedHabit;
    double lowestCompletionRate = 1.1; // Start above 100%

    for (var habit in habitBox.values) {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentCompletions = habit.completionDates.where((d) => d.isAfter(thirtyDaysAgo)).length;
      double expectedCompletions = 30.0;

      switch (habit.frequency) {
        case HabitFrequency.daily:
          expectedCompletions = 30.0;
          break;
        case HabitFrequency.specificDays:
          if (habit.specificWeekdays != null && habit.specificWeekdays!.isNotEmpty) {
            expectedCompletions = 0;
            for (int i = 0; i < 30; i++) {
              final date = DateTime.now().subtract(Duration(days: i));
              if (habit.specificWeekdays!.contains(date.weekday)) {
                expectedCompletions++;
              }
            }
          }
          break;
        case HabitFrequency.timesPerWeek:
          if (habit.weeklyTarget != null) {
            // Approximate number of weeks in 30 days
            expectedCompletions = habit.weeklyTarget! * (30 / 7);
          }
          break;
      }

      if (expectedCompletions == 0) continue; // Avoid division by zero

      final rate = recentCompletions / expectedCompletions;

      if (rate < lowestCompletionRate) {
        lowestCompletionRate = rate;
        leastCompletedHabit = habit;
      }
    }

    if (leastCompletedHabit != null && lowestCompletionRate < 0.5) { // Challenge if below 50%
      return ChallengeAnalysisResult(
        description: 'The user is struggling with the habit "${leastCompletedHabit.name}".',
        category: 'Habits',
        icon: Icons.repeat,
      );
    }
  }

  /// Finds the highest spending category in the last 30 days.
  ChallengeAnalysisResult? _findHighSpendingArea() {
    final expenseBox = Hive.box<Expense>('expenses');
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentExpenses = expenseBox.values.where((e) => e.date.isAfter(thirtyDaysAgo));

    if (recentExpenses.isEmpty) return null;

    final expensesByCategory = groupBy<Expense, ExpenseCategory>(
      recentExpenses,
      (expense) => expense.category,
    );

    final spendingByCategory = expensesByCategory.map((category, expenses) {
      return MapEntry(category, expenses.fold<double>(0, (sum, e) => sum + e.amount));
    });

    if (spendingByCategory.isEmpty) return null;

    final highestSpendingEntry = spendingByCategory.entries.reduce((a, b) => a.value > b.value ? a : b);

    // We need a way to get the category name as a string
    final categoryName = highestSpendingEntry.key.toString().split('.').last;

    return ChallengeAnalysisResult(
      description: 'The user\'s highest spending category recently has been \"$categoryName\".',
      category: 'Expenses',
      icon: Icons.attach_money,
    );
  }

  /// Finds if the user has a low water intake average over the last week.
  ChallengeAnalysisResult? _findLowWaterIntake() {
    final waterBox = Hive.box<WaterIntake>('water_intake');
    if (waterBox.values.isEmpty) return null;

    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentIntake = waterBox.values.where((i) => i.date.isAfter(sevenDaysAgo));

    if (recentIntake.isEmpty) {
      return ChallengeAnalysisResult(
        description: 'The user has not logged any water intake recently.',
        category: 'Hydration',
        icon: Icons.water_drop,
      );
    }

    final totalGlasses = recentIntake.fold<int>(0, (sum, i) => sum + i.amount);
    final averageIntake = totalGlasses / 7.0;

    // A healthy threshold could be 8 glasses a day.
    if (averageIntake < 8.0) {
      return ChallengeAnalysisResult(
        description: 'The user\'s average water intake has been low recently.',
        category: 'Hydration',
        icon: Icons.water_drop,
      );
    }

    return null;
  }
}
