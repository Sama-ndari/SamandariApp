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
          
          // Apply filters
          if (_filter.isActive) {
            tasks = tasks.where((task) => _filter.matches(task)).toList();
          }
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
            child: ReorderableListView.builder(
            onReorder: (oldIndex, newIndex) {
              _taskService.reorderTask(oldIndex, newIndex);
            },
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
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
                    subtitle: Text('${task.type.toString().split('.').last.substring(0, 1).toUpperCase()}${task.type.toString().split('.').last.substring(1)} - Due: ${DateFormat.yMd().format(task.dueDate)}'),
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
