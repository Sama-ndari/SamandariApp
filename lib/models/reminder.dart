import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 17)
enum ReminderType {
  @HiveField(0)
  task,
  @HiveField(1)
  habit,
  @HiveField(2)
  water,
  @HiveField(3)
  debt,
  @HiveField(4)
  goal,
}

@HiveType(typeId: 18)
class Reminder extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late ReminderType type;

  @HiveField(4)
  late DateTime reminderTime;

  @HiveField(5)
  late bool isEnabled;

  @HiveField(6)
  late String relatedItemId; // ID of task, habit, etc.

  @HiveField(7)
  late DateTime createdAt;

  @HiveField(8)
  bool isRecurring = false;

  @HiveField(9)
  String? recurringPattern; // 'daily', 'weekly', 'custom'
}
