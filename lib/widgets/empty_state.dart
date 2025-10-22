import 'package:flutter/material.dart';

/// A beautiful empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: (iconColor ?? theme.colorScheme.primary)
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 80,
                      color: iconColor ?? theme.colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            
            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Predefined empty states for common scenarios
class EmptyStates {
  static Widget noTasks(BuildContext context, {VoidCallback? onAdd}) {
    return EmptyState(
      icon: Icons.task_alt,
      title: 'No Tasks Yet',
      message: 'Start organizing your day by creating your first task!',
      actionLabel: 'Create Task',
      onAction: onAdd,
      iconColor: Colors.blue,
    );
  }

  static Widget noExpenses(BuildContext context, {VoidCallback? onAdd}) {
    return EmptyState(
      icon: Icons.attach_money,
      title: 'No Expenses Recorded',
      message: 'Track your spending by adding your first expense.',
      actionLabel: 'Add Expense',
      onAction: onAdd,
      iconColor: Colors.green,
    );
  }

  static Widget noNotes(BuildContext context, {VoidCallback? onAdd}) {
    return EmptyState(
      icon: Icons.note_outlined,
      title: 'No Notes Yet',
      message: 'Capture your thoughts and ideas by creating a note.',
      actionLabel: 'Create Note',
      onAction: onAdd,
      iconColor: Colors.orange,
    );
  }

  static Widget noHabits(BuildContext context, {VoidCallback? onAdd}) {
    return EmptyState(
      icon: Icons.repeat,
      title: 'No Habits to Track',
      message: 'Build better routines by creating your first habit.',
      actionLabel: 'Create Habit',
      onAction: onAdd,
      iconColor: Colors.purple,
    );
  }

  static Widget noDebts(BuildContext context, {VoidCallback? onAdd}) {
    return EmptyState(
      icon: Icons.money_off,
      title: 'No Debts to Track',
      message: 'Keep track of debts and payments by adding them here.',
      actionLabel: 'Add Debt',
      onAction: onAdd,
      iconColor: Colors.red,
    );
  }

  static Widget noGoals(BuildContext context, {VoidCallback? onAdd}) {
    return EmptyState(
      icon: Icons.flag,
      title: 'No Goals Set',
      message: 'Set meaningful goals and track your progress towards them.',
      actionLabel: 'Create Goal',
      onAction: onAdd,
      iconColor: Colors.amber,
    );
  }

  static Widget noContacts(BuildContext context, {VoidCallback? onAdd}) {
    return EmptyState(
      icon: Icons.contacts,
      title: 'No Contacts Yet',
      message: 'Add your important contacts to keep them organized.',
      actionLabel: 'Add Contact',
      onAction: onAdd,
      iconColor: Colors.teal,
    );
  }

  static Widget noSearchResults(BuildContext context) {
    return const EmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: 'Try adjusting your search or filters.',
    );
  }

  static Widget noData(BuildContext context) {
    return const EmptyState(
      icon: Icons.inbox,
      title: 'No Data Available',
      message: 'There is nothing to display at the moment.',
    );
  }

  static Widget error(BuildContext context, {String? message, VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Something Went Wrong',
      message: message ?? 'An error occurred. Please try again.',
      actionLabel: 'Retry',
      onAction: onRetry,
      iconColor: Colors.red,
    );
  }
}
