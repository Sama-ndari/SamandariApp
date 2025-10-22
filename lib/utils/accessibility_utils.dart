import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';

/// Utility class for accessibility features and helpers.
/// 
/// Provides common accessibility functions, semantic labels,
/// and screen reader support for the Samandari app.
class AccessibilityUtils {
  /// Announces a message to screen readers
  static void announceToScreenReader(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Creates semantic label for task completion
  static String taskCompletionLabel(String taskTitle, bool isCompleted) {
    return isCompleted 
      ? 'Task $taskTitle is completed'
      : 'Task $taskTitle is not completed';
  }

  /// Creates semantic label for water intake progress
  static String waterIntakeLabel(double current, double goal) {
    final percentage = ((current / goal) * 100).round();
    return 'Water intake: ${current.toInt()}ml of ${goal.toInt()}ml, $percentage percent complete';
  }

  /// Creates semantic label for expense amount
  static String expenseLabel(double amount, String currency, String category) {
    return 'Expense: $currency$amount in $category category';
  }

  /// Creates semantic label for habit streak
  static String habitStreakLabel(String habitName, int streak) {
    return 'Habit $habitName: $streak day streak';
  }
}

/// Mixin to add accessibility features to widgets
mixin AccessibilityMixin<T extends StatefulWidget> on State<T> {
  /// Provides haptic feedback for user actions
  void provideHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  /// Announces completion of an action
  void announceCompletion(String action) {
    AccessibilityUtils.announceToScreenReader(context, '$action completed');
  }
}
