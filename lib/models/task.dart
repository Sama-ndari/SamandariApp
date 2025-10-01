import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
enum TaskType {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly
}

@HiveType(typeId: 1)
enum Priority {
  @HiveField(0)
  high,
  @HiveField(1)
  medium,
  @HiveField(2)
  low
}

@HiveType(typeId: 2)
class Task extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late TaskType type;

  @HiveField(4)
  late Priority priority;

  @HiveField(5)
  late bool isCompleted;

  @HiveField(6)
  late DateTime createdDate;

  @HiveField(7)
  late DateTime dueDate;

  @HiveField(8)
  DateTime? completedDate;

  @HiveField(9)
  late DateTime assignedDate;

  @HiveField(10)
  bool isRecurring = false;

  @HiveField(11)
  String? recurringPattern; // 'daily', 'weekly', 'monthly'

  @HiveField(12)
  DateTime? lastRecurredDate;
}
