import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 12)
enum HabitFrequency {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly
}

@HiveType(typeId: 7)
class Habit extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late HabitFrequency frequency;

  @HiveField(4)
  late int color;

  @HiveField(5)
  late List<DateTime> completionDates;

  @HiveField(6)
  late DateTime createdAt;

  @HiveField(7)
  late String notes;


  @HiveField(9)
  late bool reminderEnabled;

  @HiveField(10)
  late String reminderTime; // Stored as 'HH:mm'

  // Calculate current streak
  int get currentStreak {
    if (completionDates.isEmpty) return 0;

    final sortedDates = completionDates.toList()..sort((a, b) => b.compareTo(a));
    final today = DateTime.now();
    int streak = 0;

    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final expectedDate = today.subtract(Duration(days: i));

      if (_isSameDay(date, expectedDate)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  // Get longest streak
  int get longestStreak {
    if (completionDates.isEmpty) return 0;

    final sortedDates = completionDates.toList()..sort();
    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (diff == 1) {
        currentStreak++;
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }

    return maxStreak;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
