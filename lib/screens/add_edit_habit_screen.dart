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
  List<int> _specificWeekdays = [];
  int _weeklyTarget = 1;

  @override
  void initState() {
    super.initState();
    _name = widget.habit?.name ?? '';
    _description = widget.habit?.description ?? '';
    _frequency = widget.habit?.frequency ?? HabitFrequency.daily;
    _specificWeekdays = widget.habit?.specificWeekdays ?? [];
    _weeklyTarget = widget.habit?.weeklyTarget ?? 1;
    _color = widget.habit?.color ?? Colors.blue.value;
    _notes = widget.habit?.notes ?? '';
    _reminderEnabled = widget.habit?.reminderEnabled ?? false;
    if (widget.habit?.reminderTime != null && widget.habit!.reminderTime.isNotEmpty) {
      final timeParts = widget.habit!.reminderTime.split(':');
      _reminderTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    } else {
      _reminderTime = const TimeOfDay(hour: 9, minute: 0);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      final isUpdating = widget.habit != null;

      if (isUpdating) {
        final habit = widget.habit!;
        habit
          ..name = _name
          ..description = _description
          ..frequency = _frequency
          ..color = _color
          ..notes = _notes
          ..reminderEnabled = _reminderEnabled
          ..reminderTime = '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}'
          ..specificWeekdays = _frequency == HabitFrequency.specificDays ? _specificWeekdays : null
          ..weeklyTarget = _frequency == HabitFrequency.timesPerWeek ? _weeklyTarget : null;
        _habitService.updateHabit(habit);
      } else {
        final newHabit = Habit()
          ..id = ''
          ..name = _name
          ..description = _description
          ..frequency = _frequency
          ..color = _color
          ..completionDates = []
          ..createdAt = DateTime.now()
          ..notes = _notes
          ..reminderEnabled = _reminderEnabled
          ..reminderTime = '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}'
          ..specificWeekdays = _frequency == HabitFrequency.specificDays ? _specificWeekdays : null
          ..weeklyTarget = _frequency == HabitFrequency.timesPerWeek ? _weeklyTarget : null;
        _habitService.addHabit(newHabit);
      }

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
              const Text('Frequency', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<HabitFrequency>(
                segments: const <ButtonSegment<HabitFrequency>>[
                  ButtonSegment(value: HabitFrequency.daily, label: Text('Daily')),
                  ButtonSegment(value: HabitFrequency.specificDays, label: Text('Specific Days')),
                  ButtonSegment(value: HabitFrequency.timesPerWeek, label: Text('Weekly Goal')),
                ],
                selected: {_frequency},
                onSelectionChanged: (Set<HabitFrequency> newSelection) {
                  setState(() {
                    _frequency = newSelection.first;
                  });
                },
              ),
              if (_frequency == HabitFrequency.specificDays)
                _buildSpecificDaysSelector(),
              if (_frequency == HabitFrequency.timesPerWeek)
                _buildWeeklyTargetSelector(),
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

  Widget _buildSpecificDaysSelector() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: List.generate(7, (index) {
          final dayIndex = index + 1;
          final isSelected = _specificWeekdays.contains(dayIndex);
          return ChoiceChip(
            label: Text(days[index]),
            selected: isSelected,
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  _specificWeekdays.add(dayIndex);
                } else {
                  _specificWeekdays.remove(dayIndex);
                }
                _specificWeekdays.sort();
              });
            },
          );
        }),
      ),
    );
  }

  Widget _buildWeeklyTargetSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Complete '),
          DropdownButton<int>(
            value: _weeklyTarget,
            items: List.generate(7, (i) => i + 1).map((count) {
              return DropdownMenuItem(
                value: count,
                child: Text(count.toString()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _weeklyTarget = value;
                });
              }
            },
          ),
          const Text(' times a week'),
        ],
      ),
    );
  }
}
