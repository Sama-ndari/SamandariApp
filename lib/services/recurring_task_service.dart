import 'package:hive/hive.dart';
import 'package:samapp/models/task.dart';
import 'package:uuid/uuid.dart';

class RecurringTaskService {
  final Box<Task> _taskBox = Hive.box<Task>('tasks');
  final Uuid _uuid = const Uuid();

  Future<void> checkAndCreateRecurringTasks() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final allTasks = _taskBox.values.toList();

    final recurringTemplates = allTasks.where((t) => t.isRecurring).toList();

    for (var template in recurringTemplates) {
      final instances = allTasks
          .where((t) =>
              !t.isRecurring &&
              t.recurringPattern == template.recurringPattern &&
              t.title == template.title)
          .toList();

      if (instances.isEmpty) {
        // This template has never created an instance. If its start date is today or in the past, create one.
        if (!template.dueDate.isAfter(today)) {
           await _createRecurringTaskInstance(template, fromDate: template.dueDate);
        }
        continue;
      }

      instances.sort((a, b) => b.dueDate.compareTo(a.dueDate));
      Task latestInstance = instances.first;
      DateTime lastDueDate = latestInstance.dueDate;

      // Only act if the last due date is in the past
      if (lastDueDate.isBefore(today)) {
        if (latestInstance.isCompleted) {
          // If completed, create a new instance for the current period
          await _createRecurringTaskInstance(template, fromDate: today);
        } else {
          // If not completed, roll the existing one over to today
          latestInstance.dueDate = _calculateNextDueDate(template.recurringPattern, today);
          await latestInstance.save();
        }
      }
    }
  }

  DateTime _calculateNextDueDate(String? pattern, DateTime fromDate) {
    switch (pattern) {
      case 'daily':
        return DateTime(fromDate.year, fromDate.month, fromDate.day, 23, 59, 59);
      case 'weekly':
        return fromDate.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(fromDate.year, fromDate.month + 1, fromDate.day);
      default:
        return fromDate;
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _createRecurringTaskInstance(Task template, {required DateTime fromDate}) async {
    final now = DateTime.now();
    final newDueDate = _calculateNextDueDate(template.recurringPattern, fromDate);

    final newTask = Task()
      ..id = _uuid.v4()
      ..title = template.title
      ..description = template.description
      ..type = template.type
      ..priority = template.priority
      ..isCompleted = false
      ..createdDate = now
      ..dueDate = newDueDate
      ..assignedDate = now
      ..isRecurring = false
      ..recurringPattern = template.recurringPattern; // Keep pattern for identification

    await _taskBox.put(newTask.id, newTask);
  }

  Future<void> makeTaskRecurring(
    Task task,
    String pattern, // 'daily', 'weekly', 'monthly'
  ) async {
    task.isRecurring = true;
    task.recurringPattern = pattern;
    await task.save();

    // Immediately create the first visible instance of this task
    await _createRecurringTaskInstance(task, fromDate: task.dueDate);
  }

  Future<void> stopRecurring(Task task) async {
    task.isRecurring = false;
    task.recurringPattern = null;
    await task.save();
  }
}
