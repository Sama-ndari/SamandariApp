import 'package:flutter/material.dart';
import 'package:samapp/models/task.dart';

class TaskFilterScreen extends StatefulWidget {
  final TaskFilter currentFilter;

  const TaskFilterScreen({super.key, required this.currentFilter});

  @override
  State<TaskFilterScreen> createState() => _TaskFilterScreenState();
}

class _TaskFilterScreenState extends State<TaskFilterScreen> {
  late TaskFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter.copy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Tasks'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filter = TaskFilter();
              });
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Priority Filter
          const Text(
            'Priority',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('High'),
                selected: _filter.priorities.contains(Priority.high),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _filter.priorities.add(Priority.high);
                    } else {
                      _filter.priorities.remove(Priority.high);
                    }
                  });
                },
                selectedColor: Colors.red.withOpacity(0.3),
              ),
              FilterChip(
                label: const Text('Medium'),
                selected: _filter.priorities.contains(Priority.medium),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _filter.priorities.add(Priority.medium);
                    } else {
                      _filter.priorities.remove(Priority.medium);
                    }
                  });
                },
                selectedColor: Colors.orange.withOpacity(0.3),
              ),
              FilterChip(
                label: const Text('Low'),
                selected: _filter.priorities.contains(Priority.low),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _filter.priorities.add(Priority.low);
                    } else {
                      _filter.priorities.remove(Priority.low);
                    }
                  });
                },
                selectedColor: Colors.blue.withOpacity(0.3),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Task Type Filter
          const Text(
            'Task Type',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('One-Time'),
                selected: _filter.types.contains(TaskType.oneTime),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _filter.types.add(TaskType.oneTime);
                    } else {
                      _filter.types.remove(TaskType.oneTime);
                    }
                  });
                },
              ),
              FilterChip(
                label: const Text('Recurring'),
                selected: _filter.types.contains(TaskType.recurring),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _filter.types.add(TaskType.recurring);
                    } else {
                      _filter.types.remove(TaskType.recurring);
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Status Filter
          const Text(
            'Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Show Completed'),
            value: _filter.showCompleted,
            onChanged: (value) {
              setState(() {
                _filter.showCompleted = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Show Pending'),
            value: _filter.showPending,
            onChanged: (value) {
              setState(() {
                _filter.showPending = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Show Overdue'),
            value: _filter.showOverdue,
            onChanged: (value) {
              setState(() {
                _filter.showOverdue = value;
              });
            },
          ),
          const SizedBox(height: 24),

          // Date Range Filter
          const Text(
            'Date Range',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Start Date'),
            subtitle: Text(
              _filter.startDate != null
                  ? _filter.startDate!.toString().split(' ')[0]
                  : 'Not set',
            ),
            trailing: _filter.startDate != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _filter.startDate = null;
                      });
                    },
                  )
                : null,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _filter.startDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                setState(() {
                  _filter.startDate = date;
                });
              }
            },
          ),
          ListTile(
            title: const Text('End Date'),
            subtitle: Text(
              _filter.endDate != null
                  ? _filter.endDate!.toString().split(' ')[0]
                  : 'Not set',
            ),
            trailing: _filter.endDate != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _filter.endDate = null;
                      });
                    },
                  )
                : null,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _filter.endDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                setState(() {
                  _filter.endDate = date;
                });
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_filter);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text('Apply Filters'),
        ),
      ),
    );
  }
}

class TaskFilter {
  Set<Priority> priorities = {};
  Set<TaskType> types = {};
  bool showCompleted = true;
  bool showPending = true;
  bool showOverdue = true;
  DateTime? startDate;
  DateTime? endDate;

  TaskFilter();

  TaskFilter copy() {
    return TaskFilter()
      ..priorities = Set.from(priorities)
      ..types = Set.from(types)
      ..showCompleted = showCompleted
      ..showPending = showPending
      ..showOverdue = showOverdue
      ..startDate = startDate
      ..endDate = endDate;
  }

  bool matches(Task task) {
    // Priority filter
    if (priorities.isNotEmpty && !priorities.contains(task.priority)) {
      return false;
    }

    // Type filter
    if (types.isNotEmpty && !types.contains(task.type)) {
      return false;
    }

    // Status filters
    if (task.isCompleted && !showCompleted) return false;
    if (!task.isCompleted && !showPending) return false;
    if (task.dueDate.isBefore(DateTime.now()) && !task.isCompleted && !showOverdue) {
      return false;
    }

    // Date range filter
    if (startDate != null && task.dueDate.isBefore(startDate!)) {
      return false;
    }
    if (endDate != null && task.dueDate.isAfter(endDate!)) {
      return false;
    }

    return true;
  }

  bool get isActive {
    return priorities.isNotEmpty ||
        types.isNotEmpty ||
        !showCompleted ||
        !showPending ||
        !showOverdue ||
        startDate != null ||
        endDate != null;
  }
}
