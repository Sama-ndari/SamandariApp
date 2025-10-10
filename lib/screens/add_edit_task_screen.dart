import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samapp/models/task.dart';
import 'package:samapp/models/reminder.dart';
import 'package:samapp/widgets/loading_overlay.dart';
import 'package:samapp/services/haptic_service.dart';
import 'package:samapp/widgets/in_app_notification.dart';
import 'package:samapp/services/task_service.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  final DateTime? initialDate;

  const AddEditTaskScreen({super.key, this.task, this.initialDate});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _taskService = TaskService();

  late String _title;
  late String _description;
  late DateTime _dueDate;
  late TaskType _taskType;
  late Priority _priority;
  late String? _recurringPattern;

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _dueDate = widget.task?.dueDate ?? widget.initialDate ?? DateTime.now();
    _taskType = widget.task?.isRecurring ?? false ? TaskType.recurring : TaskType.oneTime;
    _priority = widget.task?.priority ?? Priority.medium;
    _recurringPattern = widget.task?.recurringPattern;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _formKey.currentState!.save();
      
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate processing
      
      final newTask = Task()
        ..id = widget.task?.id ?? ''
        ..title = _title
        ..description = _description
        ..dueDate = _dueDate
        ..type = _taskType
        ..priority = _priority
        ..isCompleted = widget.task?.isCompleted ?? false
        ..createdDate = widget.task?.createdDate ?? DateTime.now()
        ..assignedDate = widget.task?.assignedDate ?? DateTime.now()
        ..isRecurring = _taskType == TaskType.recurring
        ..recurringPattern = _taskType == TaskType.recurring ? _recurringPattern : null;

      if (widget.task == null) {
        _taskService.addTask(newTask);
      } else {
        _taskService.updateTask(newTask);
      }

      HapticService.success();
      
      if (mounted) {
        NotificationType.success(
          context,
          title: widget.task == null ? 'Task Added!' : 'Task Updated!',
          message: _title,
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        actions: [
          if (widget.task != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Task'),
                    content: const Text('Are you sure you want to delete this task?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          _taskService.deleteTask(widget.task!.id);
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true, // Aligns the label with the top of the field
                ),
                onSaved: (value) => _description = value!,
                minLines: 3, // Set a minimum height
                maxLines: null, // Allow the field to expand indefinitely
                keyboardType: TextInputType.multiline, // Optimize keyboard for multi-line input
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text('Due Date: ${DateFormat.yMd().format(_dueDate)}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _dueDate = pickedDate;
                        });
                      }
                    },
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              DropdownButtonFormField<TaskType>(
                value: _taskType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: TaskType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type == TaskType.oneTime ? 'One-Time' : 'Recurring'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _taskType = value!;
                    if (_taskType == TaskType.oneTime) {
                      _recurringPattern = null;
                    }
                  });
                },
              ),
              if (_taskType == TaskType.recurring)
                DropdownButtonFormField<String>(
                  value: _recurringPattern,
                  hint: const Text('Select Pattern'),
                  decoration: const InputDecoration(labelText: 'Recurrence Pattern'),
                  items: ['daily', 'weekly', 'monthly'].map((pattern) {
                    return DropdownMenuItem(
                      value: pattern,
                      child: Text(pattern.substring(0, 1).toUpperCase() + pattern.substring(1)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _recurringPattern = value;
                    });
                  },
                  validator: (value) {
                    if (_taskType == TaskType.recurring && value == null) {
                      return 'Please select a recurrence pattern';
                    }
                    return null;
                  },
                ),
              DropdownButtonFormField<Priority>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: Priority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              LoadingButton(
                label: widget.task == null ? 'Add Task' : 'Update Task',
                icon: Icons.check,
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
