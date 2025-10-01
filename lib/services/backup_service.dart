import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:samapp/models/task.dart';
import 'package:samapp/models/expense.dart';
import 'package:samapp/models/note.dart';
import 'package:samapp/models/habit.dart';
import 'package:samapp/models/debt.dart';
import 'package:samapp/models/journal_entry.dart';
import 'package:samapp/models/water_intake.dart';
import 'package:samapp/models/contact.dart';
import 'package:samapp/models/goal.dart';
import 'package:intl/intl.dart';

class BackupService {
  // Export all data to a JSON file
  Future<String> exportAllData() async {
    final data = {
      'tasks': _exportBox<Task>('tasks'),
      'expenses': _exportBox<Expense>('expenses'),
      'notes': _exportBox<Note>('notes'),
      'habits': _exportBox<Habit>('habits'),
      'debts': _exportBox<Debt>('debts'),
      'journal_entries': _exportBox<JournalEntry>('journal_entries'),
      'water_intake': _exportWaterIntake(),
      'contacts': _exportBox<Contact>('contacts'),
      'goals': _exportBox<Goal>('goals'),
      'backup_date': DateTime.now().toIso8601String(),
    };

    final jsonString = jsonEncode(data);
    
    // Try to save to Downloads directory
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory!.path}/samandari_backup_$timestamp.json');
    
    await file.writeAsString(jsonString);
    return file.path;
  }

  List<Map<String, dynamic>> _exportBox<T>(String boxName) {
    final box = Hive.box<T>(boxName);
    return box.values.map<Map<String, dynamic>>((item) {
      if (item is Task) return _taskToJson(item);
      if (item is Expense) return _expenseToJson(item);
      if (item is Note) return _noteToJson(item);
      if (item is Habit) return _habitToJson(item);
      if (item is Debt) return _debtToJson(item);
      if (item is JournalEntry) return _journalEntryToJson(item);
      if (item is Contact) return _contactToJson(item);
      if (item is Goal) return _goalToJson(item);
      return <String, dynamic>{};
    }).toList();
  }

  Map<String, dynamic> _exportWaterIntake() {
    final box = Hive.box<WaterIntake>('water_intake');
    final waterIntake = box.get('water_intake');
    if (waterIntake == null) return {};
    return {
      'amount': waterIntake.amount,
      'date': waterIntake.date.toIso8601String(),
    };
  }

  // Import data from JSON file
  Future<void> importAllData(String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    // Clear all existing data
    await _clearAllData();

    // Import each module
    if (data['tasks'] != null) {
      await _importTasks(data['tasks']);
    }
    if (data['expenses'] != null) {
      await _importExpenses(data['expenses']);
    }
    if (data['notes'] != null) {
      await _importNotes(data['notes']);
    }
    if (data['habits'] != null) {
      await _importHabits(data['habits']);
    }
    if (data['debts'] != null) {
      await _importDebts(data['debts']);
    }
    if (data['journal_entries'] != null) {
      await _importJournalEntries(data['journal_entries']);
    }
    if (data['water_intake'] != null) {
      await _importWaterIntake(data['water_intake']);
    }
    if (data['contacts'] != null) {
      await _importContacts(data['contacts']);
    }
    if (data['goals'] != null) {
      await _importGoals(data['goals']);
    }
  }

  Future<void> _clearAllData() async {
    await Hive.box<Task>('tasks').clear();
    await Hive.box<Expense>('expenses').clear();
    await Hive.box<Note>('notes').clear();
    await Hive.box<Habit>('habits').clear();
    await Hive.box<Debt>('debts').clear();
    await Hive.box<JournalEntry>('journal_entries').clear();
    await Hive.box<WaterIntake>('water_intake').clear();
    await Hive.box<Contact>('contacts').clear();
    await Hive.box<Goal>('goals').clear();
  }

  // Conversion methods for each model
  Map<String, dynamic> _taskToJson(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'dueDate': task.dueDate.toIso8601String(),
      'type': task.type.toString(),
      'priority': task.priority.toString(),
      'isCompleted': task.isCompleted,
      'createdDate': task.createdDate.toIso8601String(),
      'assignedDate': task.assignedDate.toIso8601String(),
      'completedDate': task.completedDate?.toIso8601String(),
    };
  }

  Map<String, dynamic> _expenseToJson(Expense expense) {
    return {
      'id': expense.id,
      'description': expense.description,
      'amount': expense.amount,
      'category': expense.category.toString(),
      'date': expense.date.toIso8601String(),
      'createdAt': expense.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _noteToJson(Note note) {
    return {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'tags': note.tags,
      'createdAt': note.createdAt.toIso8601String(),
      'updatedAt': note.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _habitToJson(Habit habit) {
    return {
      'id': habit.id,
      'name': habit.name,
      'description': habit.description,
      'frequency': habit.frequency.toString(),
      'color': habit.color,
      'completionDates': habit.completionDates.map((d) => d.toIso8601String()).toList(),
      'createdAt': habit.createdAt.toIso8601String(),
      'notes': habit.notes,
    };
  }

  Map<String, dynamic> _debtToJson(Debt debt) {
    return {
      'id': debt.id,
      'person': debt.person,
      'amount': debt.amount,
      'description': debt.description,
      'dueDate': debt.dueDate.toIso8601String(),
      'type': debt.type.toString(),
      'isPaid': debt.isPaid,
      'createdAt': debt.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _journalEntryToJson(JournalEntry entry) {
    return {
      'id': entry.id,
      'content': entry.content,
      'mood': entry.mood.toString(),
      'tags': entry.tags,
      'date': entry.date.toIso8601String(),
    };
  }

  Map<String, dynamic> _contactToJson(Contact contact) {
    return {
      'id': contact.id,
      'name': contact.name,
      'phoneNumber': contact.phoneNumber,
      'email': contact.email,
      'createdAt': contact.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _goalToJson(Goal goal) {
    return {
      'id': goal.id,
      'title': goal.title,
      'description': goal.description,
      'type': goal.type.toString(),
      'targetAmount': goal.targetAmount,
      'currentAmount': goal.currentAmount,
      'deadline': goal.deadline.toIso8601String(),
      'createdAt': goal.createdAt.toIso8601String(),
      'isCompleted': goal.isCompleted,
    };
  }

  // Import methods
  Future<void> _importTasks(List<dynamic> tasks) async {
    final box = Hive.box<Task>('tasks');
    for (var taskData in tasks) {
      final task = Task()
        ..id = taskData['id']
        ..title = taskData['title']
        ..description = taskData['description']
        ..dueDate = DateTime.parse(taskData['dueDate'])
        ..type = _parseTaskType(taskData['type'])
        ..priority = _parsePriority(taskData['priority'])
        ..isCompleted = taskData['isCompleted']
        ..createdDate = DateTime.parse(taskData['createdDate'])
        ..assignedDate = DateTime.parse(taskData['assignedDate'])
        ..completedDate = taskData['completedDate'] != null 
            ? DateTime.parse(taskData['completedDate']) 
            : null;
      await box.put(task.id, task);
    }
  }

  Future<void> _importExpenses(List<dynamic> expenses) async {
    final box = Hive.box<Expense>('expenses');
    for (var expenseData in expenses) {
      final expense = Expense()
        ..id = expenseData['id']
        ..description = expenseData['description']
        ..amount = expenseData['amount']
        ..category = _parseExpenseCategory(expenseData['category'])
        ..date = DateTime.parse(expenseData['date'])
        ..createdAt = DateTime.parse(expenseData['createdAt']);
      await box.put(expense.id, expense);
    }
  }

  Future<void> _importNotes(List<dynamic> notes) async {
    final box = Hive.box<Note>('notes');
    for (var noteData in notes) {
      final note = Note()
        ..id = noteData['id']
        ..title = noteData['title']
        ..content = noteData['content']
        ..tags = List<String>.from(noteData['tags'])
        ..createdAt = DateTime.parse(noteData['createdAt'])
        ..updatedAt = DateTime.parse(noteData['updatedAt']);
      await box.put(note.id, note);
    }
  }

  Future<void> _importHabits(List<dynamic> habits) async {
    final box = Hive.box<Habit>('habits');
    for (var habitData in habits) {
      final habit = Habit()
        ..id = habitData['id']
        ..name = habitData['name']
        ..description = habitData['description']
        ..frequency = _parseHabitFrequency(habitData['frequency'])
        ..color = habitData['color']
        ..completionDates = (habitData['completionDates'] as List)
            .map((d) => DateTime.parse(d))
            .toList()
        ..createdAt = DateTime.parse(habitData['createdAt'])
        ..notes = habitData['notes'] ?? '';
      await box.put(habit.id, habit);
    }
  }

  Future<void> _importDebts(List<dynamic> debts) async {
    final box = Hive.box<Debt>('debts');
    for (var debtData in debts) {
      final debt = Debt()
        ..id = debtData['id']
        ..person = debtData['person']
        ..amount = debtData['amount']
        ..description = debtData['description']
        ..dueDate = DateTime.parse(debtData['dueDate'])
        ..type = _parseDebtType(debtData['type'])
        ..isPaid = debtData['isPaid']
        ..createdAt = DateTime.parse(debtData['createdAt']);
      await box.put(debt.id, debt);
    }
  }

  Future<void> _importJournalEntries(List<dynamic> entries) async {
    final box = Hive.box<JournalEntry>('journal_entries');
    for (var entryData in entries) {
      final entry = JournalEntry()
        ..id = entryData['id']
        ..content = entryData['content']
        ..mood = _parseMood(entryData['mood'])
        ..tags = List<String>.from(entryData['tags'])
        ..date = DateTime.parse(entryData['date']);
      await box.put(entry.id, entry);
    }
  }

  Future<void> _importWaterIntake(Map<String, dynamic> data) async {
    if (data.isEmpty) return;
    final box = Hive.box<WaterIntake>('water_intake');
    final waterIntake = WaterIntake()
      ..amount = data['amount'] ?? 0
      ..date = DateTime.parse(data['date']);
    await box.put('water_intake', waterIntake);
  }

  Future<void> _importContacts(List<dynamic> contacts) async {
    final box = Hive.box<Contact>('contacts');
    for (var contactData in contacts) {
      final contact = Contact()
        ..id = contactData['id']
        ..name = contactData['name']
        ..phoneNumber = contactData['phoneNumber']
        ..email = contactData['email']
        ..createdAt = DateTime.parse(contactData['createdAt']);
      await box.put(contact.id, contact);
    }
  }

  Future<void> _importGoals(List<dynamic> goals) async {
    final box = Hive.box<Goal>('goals');
    for (var goalData in goals) {
      final goal = Goal()
        ..id = goalData['id']
        ..title = goalData['title']
        ..description = goalData['description']
        ..type = _parseGoalType(goalData['type'])
        ..targetAmount = goalData['targetAmount']
        ..currentAmount = goalData['currentAmount']
        ..deadline = DateTime.parse(goalData['deadline'])
        ..createdAt = DateTime.parse(goalData['createdAt'])
        ..isCompleted = goalData['isCompleted'];
      await box.put(goal.id, goal);
    }
  }

  // Parse enum methods
  TaskType _parseTaskType(String type) {
    return TaskType.values.firstWhere((e) => e.toString() == type);
  }

  Priority _parsePriority(String priority) {
    return Priority.values.firstWhere((e) => e.toString() == priority);
  }

  ExpenseCategory _parseExpenseCategory(String category) {
    return ExpenseCategory.values.firstWhere((e) => e.toString() == category);
  }

  HabitFrequency _parseHabitFrequency(String frequency) {
    return HabitFrequency.values.firstWhere((e) => e.toString() == frequency);
  }

  DebtType _parseDebtType(String type) {
    return DebtType.values.firstWhere((e) => e.toString() == type);
  }

  Mood _parseMood(String mood) {
    return Mood.values.firstWhere((e) => e.toString() == mood);
  }

  GoalType _parseGoalType(String type) {
    return GoalType.values.firstWhere((e) => e.toString() == type);
  }
}
