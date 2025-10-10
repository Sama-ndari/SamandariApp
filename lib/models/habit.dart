import 'package:hive/hive.dart';
import 'package:samapp/services/habit_analytics_service.dart';

part 'habit.g.dart';

@HiveType(typeId: 12)
enum HabitFrequency {
  @HiveField(0)
  daily, // Every day
  @HiveField(1)
  specificDays, // e.g., Mon, Wed, Fri
  @HiveField(2)
  timesPerWeek, // e.g., 3 times a week
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

  @HiveField(8)
  List<int>? specificWeekdays; // 1 for Monday, 7 for Sunday

  @HiveField(11) // Using 11 to avoid conflict with reminderTime at 10
  int? weeklyTarget; // e.g., 3 times a week

  @HiveField(9)
  late bool reminderEnabled;

  @HiveField(10)
  late String reminderTime; // Stored as 'HH:mm'

  // Calculate current streak
  int get currentStreak => HabitAnalytics(this).currentStreak;

  // Get longest streak
  int get longestStreak => HabitAnalytics(this).longestStreak;

}
