import 'package:hive_flutter/hive_flutter.dart';
import 'package:samapp/models/expense.dart';
import 'package:samapp/models/habit.dart';
import 'package:samapp/models/journal_entry.dart';
import 'package:samapp/models/note.dart';
import 'package:samapp/models/task.dart';
import 'package:samapp/models/debt.dart';
import 'package:samapp/models/water_intake.dart';
import 'package:samapp/models/contact.dart';
import 'package:samapp/models/goal.dart';
import 'package:samapp/models/budget.dart';
import 'package:samapp/models/reminder.dart';
import 'package:samapp/models/app_statistics.dart';
import 'package:samapp/models/backup_settings.dart';
import 'package:samapp/models/pomodoro_session.dart';
import 'package:samapp/models/goal_milestone.dart';

class HiveService {
  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(TaskTypeAdapter());
    Hive.registerAdapter(PriorityAdapter());
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(ExpenseCategoryAdapter());
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(HabitFrequencyAdapter());
    Hive.registerAdapter(HabitAdapter());
    Hive.registerAdapter(MoodAdapter());
    Hive.registerAdapter(JournalEntryAdapter());
    Hive.registerAdapter(DebtTypeAdapter());
    Hive.registerAdapter(DebtAdapter());
    Hive.registerAdapter(WaterIntakeAdapter());
    Hive.registerAdapter(ContactAdapter());
    Hive.registerAdapter(GoalTypeAdapter());
    Hive.registerAdapter(GoalAdapter());
    Hive.registerAdapter(BudgetAdapter());
    Hive.registerAdapter(ReminderTypeAdapter());
    Hive.registerAdapter(ReminderAdapter());
    Hive.registerAdapter(AppStatisticsAdapter());
    Hive.registerAdapter(BackupSettingsAdapter());
    Hive.registerAdapter(PomodoroSessionAdapter());
    Hive.registerAdapter(GoalMilestoneAdapter());

    // Open Boxes
    await Hive.openBox<Task>('tasks');
    await Hive.openBox<Expense>('expenses');
    await Hive.openBox<Note>('notes');
    await Hive.openBox<Habit>('habits');
    await Hive.openBox<JournalEntry>('journal_entries');
    await Hive.openBox<Debt>('debts');
    await Hive.openBox<WaterIntake>('water_intake');
    await Hive.openBox<Contact>('contacts');
    await Hive.openBox<Goal>('goals');
    await Hive.openBox<Budget>('budgets');
    await Hive.openBox<Reminder>('reminders');
    await Hive.openBox<AppStatistics>('statistics');
    await Hive.openBox<BackupSettings>('backup_settings');
    await Hive.openBox<PomodoroSession>('pomodoro_sessions');
    await Hive.openBox<GoalMilestone>('goal_milestones');
  }
}
