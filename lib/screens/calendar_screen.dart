import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:samapp/models/task.dart';
import 'package:samapp/models/debt.dart';
import 'package:samapp/models/goal.dart';
import 'package:samapp/models/habit.dart';
import 'package:samapp/models/expense.dart';
import 'package:samapp/screens/add_edit_task_screen.dart';
import 'package:intl/intl.dart';
import 'package:samapp/utils/money_formatter.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<dynamic>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final taskBox = Hive.box<Task>('tasks');
    final debtBox = Hive.box<Debt>('debts');
    final goalBox = Hive.box<Goal>('goals');
    final habitBox = Hive.box<Habit>('habits');
    final expenseBox = Hive.box<Expense>('expenses');

    List<dynamic> events = [];

    // Add tasks for this day
    for (var task in taskBox.values) {
      if (isSameDay(task.dueDate, day)) {
        events.add({'type': 'task', 'data': task});
      }
    }

    // Add debts due on this day
    for (var debt in debtBox.values) {
      if (isSameDay(debt.dueDate, day) && !debt.isPaid) {
        events.add({'type': 'debt', 'data': debt});
      }
    }

    // Add goals with deadline on this day
    for (var goal in goalBox.values) {
      if (isSameDay(goal.deadline, day) && !goal.isCompleted) {
        events.add({'type': 'goal', 'data': goal});
      }
    }

    // Add habits completed on this day
    for (var habit in habitBox.values) {
      if (habit.completionDates.any((date) => isSameDay(date, day))) {
        events.add({'type': 'habit', 'data': habit});
      }
    }

    // Calculate total expenses for this day
    double totalExpenses = 0;
    List<Expense> dayExpenses = [];
    for (var expense in expenseBox.values) {
      if (isSameDay(expense.date, day)) {
        totalExpenses += expense.amount;
        dayExpenses.add(expense);
      }
    }
    
    // Add expenses summary if there are any expenses
    if (totalExpenses > 0) {
      events.add({
        'type': 'expense', 
        'data': {'total': totalExpenses, 'expenses': dayExpenses}
      });
    }

    return events;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
              _selectedEvents.value = _getEventsForDay(DateTime.now());
            },
            tooltip: 'Today',
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
            ),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ValueListenableBuilder<List<dynamic>>(
              valueListenable: _selectedEvents,
              builder: (context, events, _) {
                if (events.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No events on ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return _buildEventCard(event);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'calendar_fab',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditTaskScreen(initialDate: _selectedDay),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final type = event['type'] as String;
    final data = event['data'];

    IconData icon;
    Color color;
    String title;
    String subtitle;

    switch (type) {
      case 'task':
        final task = data as Task;
        icon = task.isCompleted ? Icons.check_circle : Icons.circle_outlined;
        color = task.isCompleted ? Colors.green : _getPriorityColor(task.priority);
        title = task.title;
        subtitle = task.description;
        break;
      case 'debt':
        final debt = data as Debt;
        icon = Icons.money_off;
        color = Colors.red;
        title = '${debt.type == DebtType.iOwe ? 'Pay' : 'Collect'}: ${debt.person}';
        subtitle = '${formatMoney(debt.amount)} - ${debt.description}';
        break;
      case 'goal':
        final goal = data as Goal;
        icon = Icons.flag;
        color = Colors.purple;
        title = goal.title;
        subtitle = '${goal.progressPercentage.toStringAsFixed(0)}% complete';
        break;
      case 'habit':
        final habit = data as Habit;
        icon = Icons.check_circle;
        color = Colors.green;
        title = habit.name;
        subtitle = 'Completed';
        break;
      case 'expense':
        final expenseData = data as Map<String, dynamic>;
        final total = expenseData['total'] as double;
        final expenses = expenseData['expenses'] as List<Expense>;
        icon = Icons.attach_money;
        color = Colors.green;
        title = 'Total Expenses';
        subtitle = '${formatMoney(total)} (${expenses.length} ${expenses.length == 1 ? 'transaction' : 'transactions'})';
        break;
      default:
        icon = Icons.event;
        color = Colors.grey;
        title = 'Unknown';
        subtitle = '';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: () {
          if (type == 'task') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddEditTaskScreen(task: data as Task),
              ),
            );
          }
        },
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: _buildEventBadge(type),
      ),
    );
  }

  Widget _buildEventBadge(String type) {
    String label;
    Color color;

    switch (type) {
      case 'task':
        label = 'Task';
        color = Colors.blue;
        break;
      case 'debt':
        label = 'Debt';
        color = Colors.red;
        break;
      case 'goal':
        label = 'Goal';
        color = Colors.purple;
        break;
      case 'habit':
        label = 'Habit';
        color = Colors.orange;
        break;
      case 'expense':
        label = 'Expense';
        color = Colors.green;
        break;
      default:
        label = 'Event';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.blue;
    }
  }
}
