import 'package:hive/hive.dart';

part 'pomodoro_session.g.dart';

@HiveType(typeId: 21)
class PomodoroSession extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime startTime;

  @HiveField(2)
  late DateTime? endTime;

  @HiveField(3)
  late int durationMinutes;

  @HiveField(4)
  late bool completed;

  @HiveField(5)
  late String? taskId; // Optional: link to a task

  @HiveField(6)
  late String? notes;
}
