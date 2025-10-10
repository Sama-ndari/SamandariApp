import 'dart:math';
import 'package:samapp/models/habit.dart';

class HabitAnalytics {
  final Habit habit;
  late final List<DateTime> _sortedCompletions;

  HabitAnalytics(this.habit) {
    // Sort completions once, descending, for streak calculations.
    _sortedCompletions = habit.completionDates.toList()..sort((a, b) => b.compareTo(a));
  }

  DateTime _getStartOfWeek(DateTime date) {
    final daysToSubtract = date.weekday - 1; // Assuming Monday is start of week
    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }

  // --- PUBLIC API ---

  int get currentStreak {
    if (_sortedCompletions.isEmpty) return 0;

    // A streak is broken if there was a missed opportunity between the last completion and today.
    if (_isStreakBroken()) return 0;

    // If not broken, calculate the streak ending at the last completion date.
    return _calculateStreakFromDate(_sortedCompletions.first);
  }

  int get longestStreak {
    if (_sortedCompletions.isEmpty) return 0;
    
    int maxStreak = 0;
    // Use a set to avoid recalculating from the same date multiple times.
    final checkedDates = <DateTime>{};

    for (final date in _sortedCompletions) {
      final dayOnly = DateTime(date.year, date.month, date.day);
      if (!checkedDates.contains(dayOnly)) {
        final streak = _calculateStreakFromDate(dayOnly);
        if (streak > maxStreak) {
          maxStreak = streak;
        }
        checkedDates.add(dayOnly);
      }
    }
    return maxStreak;
  }

  double getAdherenceForPeriod(DateTime start, DateTime end) {
    final expected = _getExpectedCompletions(start, end);
    if (expected == 0) return 1.0; // No tasks expected, so 100% compliant.

    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfEndDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
    final actual = habit.completionDates.where((d) => !d.isBefore(startOfDay) && d.isBefore(endOfEndDay)).toSet().length;

    final cappedActual = min(actual, expected);
    return (cappedActual / expected).clamp(0.0, 1.0);
  }

  bool wasHabitExpectedOn(DateTime date) {
    final checkDate = DateTime(date.year, date.month, date.day);
    final createdDate = DateTime(habit.createdAt.year, habit.createdAt.month, habit.createdAt.day);
    if (checkDate.isBefore(createdDate)) return false;

    switch (habit.frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.specificDays:
        return habit.specificWeekdays?.contains(checkDate.weekday) ?? false;
      case HabitFrequency.timesPerWeek:
        return true; // Any day is a potential day for a 'times per week' habit.
    }
  }

  // --- PRIVATE HELPERS ---

  int _calculateStreakFromDate(DateTime startDate) {
    final completionsSet = habit.completionDates.map((d) => DateTime(d.year, d.month, d.day)).toSet();
    if (!completionsSet.contains(startDate)) return 0;

    int streak = 0;
    DateTime currentDate = startDate;

    while (true) {
      if (completionsSet.contains(currentDate)) {
        streak++;
        currentDate = _getPreviousExpectedDate(currentDate);
      } else {
        break;
      }
    }
    return streak;
  }

  DateTime _getPreviousExpectedDate(DateTime fromDate) {
    DateTime prevDate = fromDate.subtract(const Duration(days: 1));
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return prevDate;
      case HabitFrequency.specificDays:
        while (true) {
          if (habit.specificWeekdays!.contains(prevDate.weekday)) {
            return prevDate;
          }
          prevDate = prevDate.subtract(const Duration(days: 1));
        }
      case HabitFrequency.timesPerWeek:
        // For 'times per week', streaks are measured in weeks, not days.
        // This logic is complex and better handled by a different approach.
        // The current implementation will count consecutive days, which is a reasonable proxy.
        return prevDate;
    }
  }

  bool _isStreakBroken() {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final lastCompletionDay = DateTime(_sortedCompletions.first.year, _sortedCompletions.first.month, _sortedCompletions.first.day);
    
    if (lastCompletionDay.isAtSameMomentAs(today)) return false; // Completed today, not broken.

    DateTime potentialMissDate = _getPreviousExpectedDate(today);
    return lastCompletionDay.isBefore(potentialMissDate);
  }

  int _getExpectedCompletions(DateTime start, DateTime end) {
    DateTime currentDate = DateTime(start.year, start.month, start.day);
    final DateTime finalDate = DateTime(end.year, end.month, end.day);
    if (currentDate.isAfter(finalDate)) return 0;

    int count = 0;
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return finalDate.difference(currentDate).inDays + 1;
      case HabitFrequency.specificDays:
        while (!currentDate.isAfter(finalDate)) {
          if (habit.specificWeekdays!.contains(currentDate.weekday)) {
            count++;
          }
          currentDate = currentDate.add(const Duration(days: 1));
        }
        return count;
      case HabitFrequency.timesPerWeek:
        if (finalDate.isBefore(currentDate)) return 0;
        
        DateTime weekIterator = _getStartOfWeek(currentDate);
        int expected = 0;

        while(!weekIterator.isAfter(finalDate)) {
            expected += (habit.weeklyTarget ?? 1);
            weekIterator = weekIterator.add(const Duration(days: 7));
        }
        return expected;
    }
  }
}
