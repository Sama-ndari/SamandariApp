import 'package:flutter/material.dart';
import 'package:samapp/models/habit.dart';
import 'package:samapp/services/habit_service.dart';

class AddEditHabitScreen extends StatefulWidget {
  final Habit? habit;

  const AddEditHabitScreen({super.key, this.habit});

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _habitService = HabitService();

  late String _name;
  late String _description;
  late HabitFrequency _frequency;
  late int _color;
  late String _notes;

  @override
  void initState() {
    super.initState();
    _name = widget.habit?.name ?? '';
    _description = widget.habit?.description ?? '';
    _frequency = widget.habit?.frequency ?? HabitFrequency.daily;
    _color = widget.habit?.color ?? Colors.blue.value;
    _notes = widget.habit?.notes ?? '';
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newHabit = Habit()
        ..id = widget.habit?.id ?? ''
        ..name = _name
        ..description = _description
        ..frequency = _frequency
        ..color = _color
        ..completionDates = widget.habit?.completionDates ?? []
        ..createdAt = widget.habit?.createdAt ?? DateTime.now()
        ..notes = _notes;

      if (widget.habit == null) {
        _habitService.addHabit(newHabit);
      } else {
        _habitService.updateHabit(newHabit);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? 'Add Habit' : 'Edit Habit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Add notes about your habit journey...',
                ),
                maxLines: 3,
                onSaved: (value) => _notes = value ?? '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<HabitFrequency>(
                value: _frequency,
                decoration: const InputDecoration(labelText: 'Frequency'),
                items: HabitFrequency.values.map((frequency) {
                  return DropdownMenuItem(
                    value: frequency,
                    child: Text(frequency.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _frequency = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.habit == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
