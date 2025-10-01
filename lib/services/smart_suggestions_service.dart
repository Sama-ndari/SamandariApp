import 'package:hive/hive.dart';
import 'package:samapp/models/task.dart';
import 'package:samapp/models/expense.dart';
import 'package:samapp/models/habit.dart';
import 'package:samapp/models/budget.dart';
import 'package:samapp/services/budget_service.dart';
import 'package:samapp/utils/money_formatter.dart';

class SmartSuggestionsService {
  final BudgetService _budgetService = BudgetService();

  // Get all suggestions
  List<Suggestion> getAllSuggestions() {
    final suggestions = <Suggestion>[];

    suggestions.addAll(_getBudgetSuggestions());
    suggestions.addAll(_getTaskSuggestions());
    suggestions.addAll(_getHabitSuggestions());

    // Sort by priority
    suggestions.sort((a, b) => b.priority.compareTo(a.priority));

    return suggestions;
  }

  // Budget suggestions based on spending patterns
  List<Suggestion> _getBudgetSuggestions() {
    final suggestions = <Suggestion>[];
    final spending = _budgetService.getAllMonthlySpending();

    for (var entry in spending.entries) {
      final category = entry.key;
      final amount = entry.value;
      final budget = _budgetService.getBudget(category);

      if (budget != null) {
        final percentage = (amount / budget.monthlyLimit * 100);

        if (percentage > 90) {
          suggestions.add(Suggestion(
            title: '⚠️ ${_getCategoryName(category)} Budget Alert',
            description:
                'You\'ve used ${percentage.toStringAsFixed(0)}% of your budget. Consider reducing spending.',
            type: SuggestionType.budget,
            priority: 3,
            action: 'View ${_getCategoryName(category)} expenses',
          ));
        } else if (percentage > 75) {
          suggestions.add(Suggestion(
            title: '💡 ${_getCategoryName(category)} Budget Warning',
            description:
                'You\'ve used ${percentage.toStringAsFixed(0)}% of your budget.',
            type: SuggestionType.budget,
            priority: 2,
          ));
        }
      } else if (amount > 0) {
        // Suggest creating a budget
        suggestions.add(Suggestion(
          title: '📊 Set Budget for ${_getCategoryName(category)}',
          description:
              'You\'ve spent ${formatMoney(amount)} this month. Set a budget to track spending.',
          type: SuggestionType.budget,
          priority: 1,
          action: 'Create Budget',
        ));
      }
    }

    return suggestions;
  }

  // Task suggestions based on priorities and due dates
  List<Suggestion> _getTaskSuggestions() {
    final suggestions = <Suggestion>[];
    final taskBox = Hive.box<Task>('tasks');
    final now = DateTime.now();

    int overdueTasks = 0;
    int dueSoonTasks = 0;
    int highPriorityTasks = 0;

    for (var task in taskBox.values) {
      if (!task.isCompleted) {
        if (task.dueDate.isBefore(now)) {
          overdueTasks++;
        } else if (task.dueDate.difference(now).inHours < 24) {
          dueSoonTasks++;
        }

        if (task.priority == Priority.high) {
          highPriorityTasks++;
        }
      }
    }

    if (overdueTasks > 0) {
      suggestions.add(Suggestion(
        title: '🚨 $overdueTasks Overdue Task${overdueTasks > 1 ? 's' : ''}',
        description: 'You have overdue tasks. Complete them to stay on track.',
        type: SuggestionType.task,
        priority: 3,
        action: 'View Overdue Tasks',
      ));
    }

    if (dueSoonTasks > 0) {
      suggestions.add(Suggestion(
        title: '⏰ $dueSoonTasks Task${dueSoonTasks > 1 ? 's' : ''} Due Soon',
        description: 'Tasks due in the next 24 hours.',
        type: SuggestionType.task,
        priority: 2,
        action: 'View Tasks',
      ));
    }

    if (highPriorityTasks > 3) {
      suggestions.add(Suggestion(
        title: '🎯 Focus on High Priority Tasks',
        description:
            'You have $highPriorityTasks high priority tasks. Consider completing some today.',
        type: SuggestionType.task,
        priority: 2,
      ));
    }

    return suggestions;
  }

  // Habit suggestions based on completion patterns
  List<Suggestion> _getHabitSuggestions() {
    final suggestions = <Suggestion>[];
    final habitBox = Hive.box<Habit>('habits');
    final today = DateTime.now();

    int missedToday = 0;
    List<Habit> strugglingHabits = [];

    for (var habit in habitBox.values) {
      final completedToday = habit.completionDates.any((date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day);

      if (!completedToday) {
        missedToday++;
      }

      // Check last 7 days completion rate
      final last7Days = today.subtract(const Duration(days: 7));
      final completionsLast7Days = habit.completionDates
          .where((date) => date.isAfter(last7Days))
          .length;

      if (completionsLast7Days < 3) {
        strugglingHabits.add(habit);
      }
    }

    if (missedToday > 0) {
      suggestions.add(Suggestion(
        title: '✅ Complete Today\'s Habits',
        description: '$missedToday habit${missedToday > 1 ? 's' : ''} not completed yet today.',
        type: SuggestionType.habit,
        priority: 2,
        action: 'View Habits',
      ));
    }

    if (strugglingHabits.isNotEmpty) {
      suggestions.add(Suggestion(
        title: '💪 Stay Consistent',
        description:
            '${strugglingHabits.length} habit${strugglingHabits.length > 1 ? 's' : ''} need attention. Try setting reminders.',
        type: SuggestionType.habit,
        priority: 1,
        action: 'Set Reminders',
      ));
    }

    return suggestions;
  }

  String _getCategoryName(ExpenseCategory category) {
    return category.name[0].toUpperCase() + category.name.substring(1);
  }
}

class Suggestion {
  final String title;
  final String description;
  final SuggestionType type;
  final int priority; // 1-3, higher is more important
  final String? action;

  Suggestion({
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    this.action,
  });
}

enum SuggestionType {
  budget,
  task,
  habit,
  goal,
}
