import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:samapp/models/task.dart';
import 'package:samapp/services/task_service.dart';
import 'package:samapp/screens/add_edit_task_screen.dart';
import 'package:samapp/screens/task_filter_screen.dart';
import 'package:samapp/widgets/empty_state.dart';
import 'package:samapp/widgets/animated_transitions.dart';
import 'package:samapp/services/haptic_service.dart';
import 'package:samapp/widgets/in_app_notification.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskFilter _filter = TaskFilter()..showCompleted = false;

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red.shade700;
      case Priority.medium:
        return Colors.orange.shade700;
      case Priority.low:
        return Colors.blue.shade700;
      default:
        return Colors.grey;
    }
  }
  final TaskService _taskService = TaskService();

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate.isBefore(today)) {
      return 'Overdue';
    } else if (taskDate == today) {
      return 'Today';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat.yMMMEd().format(date);
    }
  }

  Map<String, List<Task>> _groupTasks(List<Task> tasks) {
    final groups = <String, List<Task>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final overdue = tasks.where((t) => !t.isCompleted && DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day).isBefore(today)).toList();
    final todayTasks = tasks.where((t) => !t.isCompleted && isSameDay(t.dueDate, today)).toList();
    final tomorrowTasks = tasks.where((t) => !t.isCompleted && isSameDay(t.dueDate, tomorrow)).toList();
    final upcoming = tasks.where((t) => !t.isCompleted && t.dueDate.isAfter(tomorrow)).toList();
    final completed = tasks.where((t) => t.isCompleted).toList();

    if (overdue.isNotEmpty) groups['Overdue'] = overdue;
    if (todayTasks.isNotEmpty) groups['Today'] = todayTasks;
    if (tomorrowTasks.isNotEmpty) groups['Tomorrow'] = tomorrowTasks;
    if (upcoming.isNotEmpty) groups['Upcoming'] = upcoming;
    if (completed.isNotEmpty && _filter.showCompleted) groups['Completed'] = completed;

    return groups;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildTaskTile(Task task) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        HapticService.delete();
        _taskService.deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${task.title} deleted')),
        );
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [ 
            Text('Delete', style: TextStyle(color: Colors.white)),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),
      child: Hero(
        tag: 'task_${task.id}',
        child: Card(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(width: 5.0, color: _getPriorityColor(task.priority))),
            ),
            child: ListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Text('${task.type.toString().split('.').last.substring(0, 1).toUpperCase()}${task.type.toString().split('.').last.substring(1)} - Due: ${_getRelativeDate(task.dueDate)}'),
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (_) {
                  final wasCompleted = task.isCompleted;
                  _taskService.toggleTaskCompletion(task);
                  HapticService.selectionClick();
                  
                  if (!wasCompleted) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted) {
                        NotificationType.success(
                          context,
                          title: 'Task Completed! 🎉',
                          message: task.title,
                        );
                      }
                    });
                  }
                },
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddEditTaskScreen(task: task),
                  ),
                );
              },
            ), 
          ),
        ),
      ), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_filter.isActive)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                child: IconButton(
                  icon: const Icon(Icons.filter_alt_off),
                  onPressed: () {
                    setState(() {
                      _filter = TaskFilter();
                    });
                  },
                  tooltip: 'Clear Filters',
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: IconButton(
                icon: Icon(_filter.isActive ? Icons.filter_alt : Icons.filter_alt_outlined),
                onPressed: () async {
                  final result = await Navigator.of(context).push<TaskFilter>(
                    MaterialPageRoute(
                      builder: (context) => TaskFilterScreen(currentFilter: _filter),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _filter = result;
                    });
                  }
                },
                tooltip: 'Filter Tasks',
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Task>('tasks').listenable(),
        builder: (context, Box<Task> box, _) {
          var tasks = box.values.toList().cast<Task>();

          // Automatically update overdue tasks
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          for (var task in tasks) {
            if (!task.isCompleted && task.dueDate.isBefore(today)) {
              task.dueDate = today;
              _taskService.updateTask(task);
            }
          }
          
          // Apply filters
          if (_filter.isActive) {
            tasks = tasks.where((task) => _filter.matches(task)).toList();
          }
          // Group tasks
          final groupedTasks = _groupTasks(tasks);
          final groupKeys = groupedTasks.keys.toList();

          if (tasks.isEmpty) {
            return EmptyStates.noTasks(
              context,
              onAdd: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddEditTaskScreen(),
                  ),
                );
              },
            );
          }

          return SlideInFromBottom(
            child: ListView.builder(
              itemCount: groupKeys.length,
              itemBuilder: (context, index) {
                final groupName = groupKeys[index];
                final groupTasks = groupedTasks[groupName]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      margin: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        groupName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                    ...groupTasks.map((task) => _buildTaskTile(task)),
                  ],
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'tasks_fab',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditTaskScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
