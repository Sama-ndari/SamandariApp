import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 13)
enum GoalType {
  @HiveField(0)
  savings,
  @HiveField(1)
  fitness,
  @HiveField(2)
  learning,
  @HiveField(3)
  personal,
  @HiveField(4)
  other,
}

@HiveType(typeId: 14)
class Goal extends HiveObject {
  Goal();

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late GoalType type;

  @HiveField(4)
  late double targetAmount;

  @HiveField(5)
  late double currentAmount;

  @HiveField(6)
  late DateTime deadline;

  @HiveField(7)
  late DateTime createdAt;

  @HiveField(8)
  late bool isCompleted;

  // Calculate progress percentage
  double get progressPercentage {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount * 100).clamp(0, 100);
  }

  // Check if goal is overdue
  bool get isOverdue {
    return !isCompleted && DateTime.now().isAfter(deadline);
  }
}
