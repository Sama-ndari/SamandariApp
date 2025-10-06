import 'package:flutter/material.dart';
import 'package:samapp/models/habit.dart';
import 'package:samapp/services/habit_service.dart';
import 'package:samapp/services/notification_service.dart';

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
  late bool _reminderEnabled;
  late TimeOfDay _reminderTime;
  late HabitType _type;
  late double? _goalValue;
  late String? _goalUnit;

  @override
  void initState() {
    super.initState();
    _name = widget.habit?.name ?? '';
    _description = widget.habit?.description ?? '';
    _frequency = widget.habit?.frequency ?? HabitFrequency.daily;
    _color = widget.habit?.color ?? Colors.blue.value;
    _notes = widget.habit?.notes ?? '';
    _reminderEnabled = widget.habit?.reminderEnabled ?? false;
    if (widget.habit?.reminderTime != null && widget.habit!.reminderTime!.isNotEmpty) {
      final timeParts = widget.habit!.reminderTime!.split(':');
      _reminderTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    } else {
      _reminderTime = const TimeOfDay(hour: 9, minute: 0);
    }
    _type = widget.habit?.type ?? HabitType.yesNo;
    _goalValue = widget.habit?.goalValue;
    _goalUnit = widget.habit?.goalUnit;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      final isUpdating = widget.habit != null;

      if (isUpdating) {
        // Update existing habit
        final habit = widget.habit!;
        habit
          ..name = _name
          ..description = _description
          ..frequency = _frequency
          ..color = _color
          ..notes = _notes
          ..type = _type
          ..goalValue = _type != HabitType.yesNo ? _goalValue : null
          ..goalUnit = _type != HabitType.yesNo ? _goalUnit : null
          ..reminderEnabled = _reminderEnabled
          ..reminderTime = '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';
        _habitService.updateHabit(habit);
      } else {
        // Create new habit and initialize all fields
        final newHabit = Habit()
          ..id = '' // Service will assign it
          ..name = _name
          ..description = _description
          ..frequency = _frequency
          ..color = _color
          ..completionDates = []
          ..createdAt = DateTime.now()
          ..notes = _notes
          ..reminderEnabled = _reminderEnabled
          ..reminderTime = '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}'
          ..type = _type
          ..goalValue = _type != HabitType.yesNo ? _goalValue : null
          ..goalUnit = _type != HabitType.yesNo ? _goalUnit : null;
        _habitService.addHabit(newHabit);
      }

      // Handle notification scheduling
      final notificationService = NotificationService();
      if (_reminderEnabled) {
        final habitToSchedule = isUpdating ? widget.habit! : _habitService.getHabitByName(_name);
        if (habitToSchedule != null) {
          final now = DateTime.now();
          final reminderDateTime = DateTime(now.year, now.month, now.day, _reminderTime.hour, _reminderTime.minute);
          notificationService.scheduleHabitReminder(habitToSchedule, reminderDateTime);
        }
      } else if (isUpdating) {
        notificationService.cancelNotification(widget.habit!.id.hashCode);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
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
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<HabitType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Habit Type'),
                items: HabitType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
              ),
              if (_type == HabitType.measurable || _type == HabitType.timed)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _goalValue?.toString(),
                        decoration: const InputDecoration(labelText: 'Goal'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a goal';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (value) => _goalValue = double.parse(value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: _goalUnit,
                        decoration: const InputDecoration(labelText: 'Unit (e.g., km, min)'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a unit';
                          }
                          return null;
                        },
                        onSaved: (value) => _goalUnit = value!,
                      ),
                    ),
                  ],
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
              const Divider(),
              SwitchListTile(
                title: const Text('Enable Reminder'),
                value: _reminderEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _reminderEnabled = value;
                  });
                },
              ),
              if (_reminderEnabled)
                ListTile(
                  title: const Text('Reminder Time'),
                  subtitle: Text(_reminderTime.format(context)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: _reminderTime,
                    );
                    if (picked != null && picked != _reminderTime) {
                      setState(() {
                        _reminderTime = picked;
                      });
                    }
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
