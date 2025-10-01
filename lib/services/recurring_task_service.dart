import 'package:hive/hive.dart';
import 'package:samapp/models/task.dart';
import 'package:uuid/uuid.dart';

class RecurringTaskService {
  final Box<Task> _taskBox = Hive.box<Task>('tasks');
  final Uuid _uuid = const Uuid();

  Future<void> checkAndCreateRecurringTasks() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var task in _taskBox.values) {
      if (task.isRecurring && task.recurringPattern != null) {
        final lastRecurred = task.lastRecurredDate ?? task.createdDate;
        final lastRecurredDate = DateTime(
          lastRecurred.year,
          lastRecurred.month,
          lastRecurred.day,
        );

        bool shouldCreateNew = false;

        switch (task.recurringPattern) {
          case 'daily':
            shouldCreateNew = today.isAfter(lastRecurredDate);
            break;
          case 'weekly':
            final daysDifference = today.difference(lastRecurredDate).inDays;
            shouldCreateNew = daysDifference >= 7;
            break;
          case 'monthly':
            shouldCreateNew = today.month != lastRecurredDate.month ||
                today.year != lastRecurredDate.year;
            break;
        }

        if (shouldCreateNew) {
          await _createRecurringTaskInstance(task);
          task.lastRecurredDate = now;
          await task.save();
        }
      }
    }
  }

  Future<void> _createRecurringTaskInstance(Task originalTask) async {
    final now = DateTime.now();
    DateTime newDueDate;

    switch (originalTask.recurringPattern) {
      case 'daily':
        newDueDate = DateTime(now.year, now.month, now.day, 23, 59);
        break;
      case 'weekly':
        newDueDate = now.add(const Duration(days: 7));
        break;
      case 'monthly':
        newDueDate = DateTime(now.year, now.month + 1, now.day);
        break;
      default:
        newDueDate = now;
    }

    final newTask = Task()
      ..id = _uuid.v4()
      ..title = originalTask.title
      ..description = originalTask.description
      ..type = originalTask.type
      ..priority = originalTask.priority
      ..isCompleted = false
      ..createdDate = now
      ..dueDate = newDueDate
      ..assignedDate = now
      ..isRecurring = false // The instance itself is not recurring
      ..recurringPattern = null
      ..lastRecurredDate = null;

    await _taskBox.put(newTask.id, newTask);
  }

  Future<void> makeTaskRecurring(
    Task task,
    String pattern, // 'daily', 'weekly', 'monthly'
  ) async {
    task.isRecurring = true;
    task.recurringPattern = pattern;
    task.lastRecurredDate = DateTime.now();
    await task.save();
  }

  Future<void> stopRecurring(Task task) async {
    task.isRecurring = false;
    task.recurringPattern = null;
    task.lastRecurredDate = null;
    await task.save();
  }
}
