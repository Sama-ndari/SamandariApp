import 'package:hive/hive.dart';
import 'package:samapp/models/task.dart';
import 'package:uuid/uuid.dart';

class TaskService {
  final Box<Task> _taskBox = Hive.box<Task>('tasks');
  final _uuid = const Uuid();

  // Get all tasks
  List<Task> getAllTasks() {
    return _taskBox.values.toList();
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    task.id = _uuid.v4();
    await _taskBox.add(task);
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    final taskKey = _taskBox.keys.firstWhere((key) => _taskBox.get(key)!.id == task.id, orElse: () => null);
    if (taskKey != null) {
      await _taskBox.put(taskKey, task);
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    final taskKey = _taskBox.keys.firstWhere((key) => _taskBox.get(key)!.id == taskId, orElse: () => null);
    if (taskKey != null) {
      await _taskBox.delete(taskKey);
    }
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    task.completedDate = task.isCompleted ? DateTime.now() : null;
    await updateTask(task);
  }

  // Reorder a task
  Future<void> reorderTask(int oldIndex, int newIndex) async {
    final tasks = _taskBox.values.toList();

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);

    await _taskBox.clear();

    for (int i = 0; i < tasks.length; i++) {
      await _taskBox.put(i, tasks[i]);
    }
  }
}
