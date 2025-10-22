// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Samandari';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get tasks => 'Tasks';

  @override
  String get expenses => 'Expenses';

  @override
  String get notes => 'Notes';

  @override
  String get water => 'Water';

  @override
  String get habits => 'Habits';

  @override
  String get debts => 'Debts';

  @override
  String get soulSync => 'SoulSync';

  @override
  String get goals => 'Goals';

  @override
  String get addTask => 'Add Task';

  @override
  String get editTask => 'Edit Task';

  @override
  String get deleteTask => 'Delete Task';

  @override
  String get taskTitle => 'Task Title';

  @override
  String get taskDescription => 'Description';

  @override
  String get dueDate => 'Due Date';

  @override
  String get priority => 'Priority';

  @override
  String get high => 'High';

  @override
  String get medium => 'Medium';

  @override
  String get low => 'Low';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get noTasksYet => 'No tasks yet';

  @override
  String get createFirstTask => 'Create your first task to get started!';

  @override
  String waterIntakeGoal(int goal) {
    return 'Daily Goal: ${goal}ml';
  }

  @override
  String waterIntakeProgress(int current, int goal) {
    return '${current}ml of ${goal}ml';
  }

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get goalReached => 'You\'ve reached your daily water goal!';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get description => 'Description';

  @override
  String get noExpensesYet => 'No expenses yet';

  @override
  String get startTrackingExpenses =>
      'Start tracking your expenses to manage your budget!';

  @override
  String get addNote => 'Add Note';

  @override
  String get noteTitle => 'Note Title';

  @override
  String get noteContent => 'Content';

  @override
  String get noNotesYet => 'No notes yet';

  @override
  String get createFirstNote =>
      'Create your first note to capture your thoughts!';

  @override
  String get search => 'Search';

  @override
  String get searchResults => 'Search Results';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryDifferentKeywords =>
      'Try different keywords or check your spelling';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemMode => 'System';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get backup => 'Backup';

  @override
  String get backupNow => 'Backup Now';

  @override
  String get restore => 'Restore';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get success => 'Success';

  @override
  String get taskCompleted => 'Task completed!';

  @override
  String get taskAdded => 'Task added successfully';

  @override
  String get expenseAdded => 'Expense added successfully';

  @override
  String get noteAdded => 'Note added successfully';

  @override
  String get backupCreated => 'Backup created successfully';

  @override
  String get dataRestored => 'Data restored successfully';
}
