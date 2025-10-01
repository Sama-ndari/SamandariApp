import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:samapp/models/task.dart';
import 'package:samapp/models/expense.dart';
import 'package:samapp/models/note.dart';
import 'package:samapp/models/habit.dart';
import 'package:samapp/models/debt.dart';
import 'package:samapp/models/goal.dart';
import 'package:samapp/models/contact.dart';
import 'package:samapp/screens/add_edit_task_screen.dart';
import 'package:samapp/screens/add_edit_expense_screen.dart';
import 'package:samapp/screens/add_edit_note_screen.dart';
import 'package:samapp/screens/habit_details_screen.dart';
import 'package:samapp/screens/add_edit_debt_screen.dart';
import 'package:samapp/screens/add_edit_goal_screen.dart';
import 'package:samapp/screens/add_edit_contact_screen.dart';
import 'package:samapp/utils/money_formatter.dart';
import 'package:samapp/widgets/empty_state.dart';
import 'package:samapp/widgets/animated_transitions.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final results = <Map<String, dynamic>>[];
    final queryLower = query.toLowerCase();

    // Search Tasks
    final taskBox = Hive.box<Task>('tasks');
    for (var task in taskBox.values) {
      if (task.title.toLowerCase().contains(queryLower) ||
          task.description.toLowerCase().contains(queryLower)) {
        results.add({
          'type': 'Task',
          'icon': Icons.check_circle_outline,
          'color': Colors.blue,
          'title': task.title,
          'subtitle': task.description,
          'data': task,
        });
      }
    }

    // Search Expenses
    final expenseBox = Hive.box<Expense>('expenses');
    for (var expense in expenseBox.values) {
      if (expense.description.toLowerCase().contains(queryLower)) {
        results.add({
          'type': 'Expense',
          'icon': Icons.attach_money,
          'color': Colors.green,
          'title': expense.description,
          'subtitle': '${formatMoney(expense.amount)} - ${expense.category.name}',
          'data': expense,
        });
      }
    }

    // Search Notes
    final noteBox = Hive.box<Note>('notes');
    for (var note in noteBox.values) {
      if (note.title.toLowerCase().contains(queryLower) ||
          note.content.toLowerCase().contains(queryLower) ||
          note.tags.any((tag) => tag.toLowerCase().contains(queryLower))) {
        results.add({
          'type': 'Note',
          'icon': Icons.note,
          'color': Colors.orange,
          'title': note.title,
          'subtitle': note.content.length > 50
              ? '${note.content.substring(0, 50)}...'
              : note.content,
          'data': note,
        });
      }
    }

    // Search Habits
    final habitBox = Hive.box<Habit>('habits');
    for (var habit in habitBox.values) {
      if (habit.name.toLowerCase().contains(queryLower) ||
          habit.description.toLowerCase().contains(queryLower)) {
        results.add({
          'type': 'Habit',
          'icon': Icons.repeat,
          'color': Colors.purple,
          'title': habit.name,
          'subtitle': habit.description,
          'data': habit,
        });
      }
    }

    // Search Debts
    final debtBox = Hive.box<Debt>('debts');
    for (var debt in debtBox.values) {
      if (debt.person.toLowerCase().contains(queryLower) ||
          debt.description.toLowerCase().contains(queryLower)) {
        results.add({
          'type': 'Debt',
          'icon': Icons.money_off,
          'color': Colors.red,
          'title': debt.person,
          'subtitle': '${formatMoney(debt.amount)} - ${debt.description}',
          'data': debt,
        });
      }
    }

    // Search Goals
    final goalBox = Hive.box<Goal>('goals');
    for (var goal in goalBox.values) {
      if (goal.title.toLowerCase().contains(queryLower) ||
          goal.description.toLowerCase().contains(queryLower)) {
        results.add({
          'type': 'Goal',
          'icon': Icons.flag,
          'color': Colors.indigo,
          'title': goal.title,
          'subtitle': goal.description,
          'data': goal,
        });
      }
    }

    // Search Contacts
    final contactBox = Hive.box<Contact>('contacts');
    for (var contact in contactBox.values) {
      if (contact.name.toLowerCase().contains(queryLower) ||
          contact.phoneNumber.toLowerCase().contains(queryLower) ||
          contact.email.toLowerCase().contains(queryLower)) {
        results.add({
          'type': 'Contact',
          'icon': Icons.person,
          'color': Colors.teal,
          'title': contact.name,
          'subtitle': '${contact.phoneNumber} • ${contact.email}',
          'data': contact,
        });
      }
    }

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search everything...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          onChanged: _performSearch,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
        ],
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty
              ? _searchController.text.isEmpty
                  ? const EmptyState(
                      icon: Icons.search,
                      title: 'Global Search',
                      message: 'Search across all your tasks, notes, expenses, habits, and more',
                    )
                  : EmptyStates.noSearchResults(context)
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '${_searchResults.length} result${_searchResults.length != 1 ? 's' : ''} found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    (result['color'] as Color).withOpacity(0.2),
                                child: Icon(
                                  result['icon'] as IconData,
                                  color: result['color'] as Color,
                                ),
                              ),
                              title: Text(result['title'] as String),
                              subtitle: Text(
                                result['subtitle'] as String,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: (result['color'] as Color)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: (result['color'] as Color)
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  result['type'] as String,
                                  style: TextStyle(
                                    color: result['color'] as Color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              onTap: () => _navigateToItem(result),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
  
  void _navigateToItem(Map<String, dynamic> result) {
    final type = result['type'] as String;
    final data = result['data'];
    
    Widget? screen;
    
    switch (type) {
      case 'Task':
        screen = AddEditTaskScreen(task: data as Task);
        break;
      case 'Expense':
        screen = AddEditExpenseScreen(expense: data as Expense);
        break;
      case 'Note':
        screen = AddEditNoteScreen(note: data as Note);
        break;
      case 'Habit':
        screen = HabitDetailsScreen(habit: data as Habit);
        break;
      case 'Debt':
        screen = AddEditDebtScreen(debt: data as Debt);
        break;
      case 'Goal':
        screen = AddEditGoalScreen(goal: data as Goal);
        break;
      case 'Contact':
        screen = AddEditContactScreen(contact: data as Contact);
        break;
    }
    
    if (screen != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => screen!),
      );
    }
  }
}
