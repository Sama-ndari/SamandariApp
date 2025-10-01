import 'package:hive/hive.dart';

part 'app_statistics.g.dart';

@HiveType(typeId: 19)
class AppStatistics extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late int tasksCompleted;

  @HiveField(3)
  late int habitsCompleted;

  @HiveField(4)
  late double totalExpenses;

  @HiveField(5)
  late int waterGlasses;

  @HiveField(6)
  late int notesCreated;

  @HiveField(7)
  late int goalsAchieved;

  @HiveField(8)
  late DateTime createdAt;
}
