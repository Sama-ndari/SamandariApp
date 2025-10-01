import 'package:samapp/models/habit.dart';

class HabitStreakService {
  // Calculate current streak
  int getCurrentStreak(Habit habit) {
    if (habit.completionDates.isEmpty) return 0;

    final sortedDates = habit.completionDates.toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending

    int streak = 0;
    DateTime checkDate = DateTime.now();
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

    for (var completionDate in sortedDates) {
      final normalized = DateTime(
        completionDate.year,
        completionDate.month,
        completionDate.day,
      );

      if (normalized.isAtSameMomentAs(checkDate) ||
          normalized.isAtSameMomentAs(checkDate.subtract(const Duration(days: 1)))) {
        streak++;
        checkDate = normalized.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  // Calculate longest streak
  int getLongestStreak(Habit habit) {
    if (habit.completionDates.isEmpty) return 0;

    final sortedDates = habit.completionDates.toList()
      ..sort((a, b) => a.compareTo(b)); // Sort ascending

    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final prevDate = DateTime(
        sortedDates[i - 1].year,
        sortedDates[i - 1].month,
        sortedDates[i - 1].day,
      );
      final currDate = DateTime(
        sortedDates[i].year,
        sortedDates[i].month,
        sortedDates[i].day,
      );

      final difference = currDate.difference(prevDate).inDays;

      if (difference == 1) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else if (difference > 1) {
        currentStreak = 1;
      }
    }

    return longestStreak;
  }

  // Get completion rate for last N days
  double getCompletionRate(Habit habit, int days) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    int completedDays = 0;
    for (var date in habit.completionDates) {
      if (date.isAfter(startDate) && date.isBefore(now)) {
        completedDays++;
      }
    }

    return (completedDays / days * 100).clamp(0, 100);
  }

  // Check if completed today
  bool isCompletedToday(Habit habit) {
    final today = DateTime.now();
    return habit.completionDates.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  // Get heatmap data for last 90 days
  Map<DateTime, int> getHeatmapData(Habit habit) {
    final Map<DateTime, int> heatmap = {};
    final now = DateTime.now();

    // Initialize last 90 days
    for (int i = 0; i < 90; i++) {
      final date = now.subtract(Duration(days: i));
      final normalized = DateTime(date.year, date.month, date.day);
      heatmap[normalized] = 0;
    }

    // Mark completed dates
    for (var completionDate in habit.completionDates) {
      final normalized = DateTime(
        completionDate.year,
        completionDate.month,
        completionDate.day,
      );
      if (heatmap.containsKey(normalized)) {
        heatmap[normalized] = 1;
      }
    }

    return heatmap;
  }

  // Get streak badge
  String getStreakBadge(int streak) {
    if (streak >= 365) return '🏆 Legend';
    if (streak >= 180) return '💎 Diamond';
    if (streak >= 90) return '🥇 Gold';
    if (streak >= 30) return '🥈 Silver';
    if (streak >= 7) return '🥉 Bronze';
    if (streak >= 3) return '⭐ Starter';
    return '🌱 Beginner';
  }
}
