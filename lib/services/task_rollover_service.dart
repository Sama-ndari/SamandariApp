import 'package:hive/hive.dart';
import 'package:samapp/models/task.dart';
import 'package:samapp/services/task_service.dart';

class TaskRolloverService {
  final Box<Task> _taskBox = Hive.box<Task>('tasks');
  final TaskService _taskService = TaskService();

  Future<void> rolloverTasks() async {
    final now = DateTime.now();
    final tasksToUpdate = <Task>[];

    for (final task in _taskBox.values) {
      if (task.isCompleted) continue;

      bool needsRollover = false;
      DateTime newAssignedDate = task.assignedDate;

      switch (task.type) {
        case TaskType.daily:
          if (!_isSameDay(task.assignedDate, now)) {
            needsRollover = true;
            newAssignedDate = now;
          }
          break;
        case TaskType.weekly:
          if (!_isSameWeek(task.assignedDate, now)) {
            needsRollover = true;
            newAssignedDate = now;
          }
          break;
        case TaskType.monthly:
          if (!_isSameMonth(task.assignedDate, now)) {
            needsRollover = true;
            newAssignedDate = now;
          }
          break;
      }

      if (needsRollover) {
        task.assignedDate = newAssignedDate;

        // Also update the due date
        switch (task.type) {
          case TaskType.daily:
            task.dueDate = newAssignedDate;
            break;
          case TaskType.weekly:
            task.dueDate = task.dueDate.add(const Duration(days: 7));
            break;
          case TaskType.monthly:
            task.dueDate = DateTime(task.dueDate.year, task.dueDate.month + 1, task.dueDate.day);
            break;
        }

        tasksToUpdate.add(task);
      }
    }

    for (final task in tasksToUpdate) {
      await _taskService.updateTask(task);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameWeek(DateTime a, DateTime b) {
    final aWeek = a.weekday;
    final bWeek = b.weekday;
    final aDay = a.day;
    final bDay = b.day;

    return a.year == b.year &&
        a.month == b.month &&
        (aDay - aWeek) == (bDay - bWeek);
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}
