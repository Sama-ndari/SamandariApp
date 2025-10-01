import 'package:hive/hive.dart';

part 'goal_milestone.g.dart';

@HiveType(typeId: 22)
class GoalMilestone extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String goalId;

  @HiveField(2)
  late String title;

  @HiveField(3)
  late String description;

  @HiveField(4)
  late double targetAmount;

  @HiveField(5)
  late bool isCompleted;

  @HiveField(6)
  late DateTime? completedAt;

  @HiveField(7)
  late DateTime createdAt;

  @HiveField(8)
  late int order; // Order in the milestone sequence
}
