import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samapp/models/goal.dart';
import 'package:samapp/services/goal_service.dart';

class AddEditGoalScreen extends StatefulWidget {
  final Goal? goal;

  const AddEditGoalScreen({super.key, this.goal});

  @override
  State<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _goalService = GoalService();

  late String _title;
  late String _description;
  late GoalType _type;
  late double _targetAmount;
  late double _currentAmount;
  late DateTime _deadline;

  @override
  void initState() {
    super.initState();
    _title = widget.goal?.title ?? '';
    _description = widget.goal?.description ?? '';
    _type = widget.goal?.type ?? GoalType.savings;
    _targetAmount = widget.goal?.targetAmount ?? 0.0;
    _currentAmount = widget.goal?.currentAmount ?? 0.0;
    _deadline = widget.goal?.deadline ?? DateTime.now().add(const Duration(days: 30));
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newGoal = Goal()
        ..id = widget.goal?.id ?? ''
        ..title = _title
        ..description = _description
        ..type = _type
        ..targetAmount = _targetAmount
        ..currentAmount = _currentAmount
        ..deadline = _deadline
        ..createdAt = widget.goal?.createdAt ?? DateTime.now()
        ..isCompleted = widget.goal?.isCompleted ?? false;

      if (widget.goal == null) {
        _goalService.addGoal(newGoal);
      } else {
        _goalService.updateGoal(newGoal);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal == null ? 'Add Goal' : 'Edit Goal'),
        actions: [
          if (widget.goal != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Goal'),
                    content: const Text('Are you sure you want to delete this goal?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          _goalService.deleteGoal(widget.goal!.id);
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
          if (widget.goal != null && !widget.goal!.isCompleted)
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: () {
                _goalService.completeGoal(widget.goal!.id);
                Navigator.of(context).pop();
              },
              tooltip: 'Mark as Complete',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
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
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<GoalType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: GoalType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last[0].toUpperCase() + 
                               type.toString().split('.').last.substring(1)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _targetAmount.toString(),
                decoration: const InputDecoration(labelText: 'Target Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                onSaved: (value) => _targetAmount = double.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _currentAmount.toString(),
                decoration: const InputDecoration(labelText: 'Current Progress'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                onSaved: (value) => _currentAmount = double.parse(value!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text('Deadline: ${DateFormat.yMd().format(_deadline)}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _deadline,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _deadline = pickedDate;
                        });
                      }
                    },
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.goal == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
