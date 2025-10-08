import 'package:hive/hive.dart';
import 'package:samapp/models/habit.dart';
import 'package:uuid/uuid.dart';

class HabitService {
  final Box<Habit> _habitBox = Hive.box<Habit>('habits');
  final _uuid = const Uuid();

  List<Habit> getAllHabits() {
    return _habitBox.values.toList();
  }

  Habit? getHabitByName(String name) {
    try {
      return _habitBox.values.firstWhere((h) => h.name == name);
    } catch (e) {
      return null;
    }
  }

  Future<void> addHabit(Habit habit) async {
    habit.id = _uuid.v4();
    await _habitBox.put(habit.id, habit);
  }

  Future<void> updateHabit(Habit habit) async {
    await _habitBox.put(habit.id, habit);
  }

  Future<void> deleteHabit(String habitId) async {
    await _habitBox.delete(habitId);
  }


  Future<void> toggleHabitCompletion(Habit habit) async {
    final today = DateTime.now();
    final todayWithoutTime = DateTime(today.year, today.month, today.day);

    // For weekly habits, we just add a completion, we don't remove.
    if (habit.frequency == HabitFrequency.timesPerWeek) {
      // Prevent adding more completions than the target
      if (getCompletionsThisWeek(habit) < (habit.weeklyTarget ?? 1)) {
        habit.completionDates.add(todayWithoutTime);
      }
    } else {
      // For daily and specific day habits, we toggle.
      if (habit.completionDates.contains(todayWithoutTime)) {
        habit.completionDates.remove(todayWithoutTime);
      } else {
        habit.completionDates.add(todayWithoutTime);
      }
    }
    await updateHabit(habit);
  }

  bool isHabitDueToday(Habit habit) {
    final today = DateTime.now();
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.specificDays:
        return habit.specificWeekdays?.contains(today.weekday) ?? false;
      case HabitFrequency.timesPerWeek:
        // A weekly habit is always 'due' until the target is met for the week.
        return getCompletionsThisWeek(habit) < (habit.weeklyTarget ?? 1);
    }
  }

  int getCompletionsThisWeek(Habit habit) {
    if (habit.frequency != HabitFrequency.timesPerWeek) return 0;

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return habit.completionDates.where((date) {
      final d = DateTime(date.year, date.month, date.day);
      return !d.isBefore(DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)) && 
             !d.isAfter(DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day));
    }).length;
  }

  Future<void> addCompletion(Habit habit) async {
    habit.completionDates.add(DateTime.now());
    await updateHabit(habit);
  }

  Future<void> removeLastCompletion(Habit habit) async {
    if (habit.completionDates.isNotEmpty) {
      habit.completionDates.sort((a, b) => a.compareTo(b));
      habit.completionDates.removeLast();
      await updateHabit(habit);
    }
  }

  int calculateStreak(Habit habit) {
    if (habit.completionDates.isEmpty) return 0;

    final dates = habit.completionDates.toSet().toList();
    dates.sort((a, b) => b.compareTo(a)); 

    int streak = 0;
    DateTime today = DateTime.now();
    DateTime currentDate = DateTime(today.year, today.month, today.day);

    if (dates.first.isAtSameMomentAs(currentDate)) {
      streak++;
    } else if (dates.first.isAtSameMomentAs(currentDate.subtract(const Duration(days: 1)))) {
      streak++;
    } else {
      return 0;
    }

    for (int i = 0; i < dates.length - 1; i++) {
      final difference = dates[i].difference(dates[i + 1]).inDays;
      if (difference == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
