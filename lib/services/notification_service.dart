import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:samapp/services/logging_service.dart';
import 'package:hive/hive.dart';
import 'package:samapp/models/reminder.dart';
import 'package:samapp/models/task.dart' as task_model;
import 'package:samapp/models/habit.dart';
import 'package:samapp/models/debt.dart';
import 'package:samapp/models/goal.dart';
import 'package:samapp/utils/money_formatter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    AppLogger.info('Notification tapped: ${response.payload}');
  }

  // Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'samandari_channel',
          'Samandari Notifications',
          channelDescription: 'Notifications for tasks, habits, and reminders',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancel a notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Schedule task reminder
  Future<void> scheduleTaskReminder(task_model.Task task) async {
    if (task.dueDate.isAfter(DateTime.now())) {
      // Schedule 1 hour before due date
      final reminderTime = task.dueDate.subtract(const Duration(hours: 1));
      
      if (reminderTime.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: task.id.hashCode,
          title: 'Task Due Soon: ${task.title}',
          body: 'Due in 1 hour',
          scheduledTime: reminderTime,
          payload: 'task_${task.id}',
        );
      }
    }
  }

  // Schedule habit reminder
  Future<void> scheduleHabitReminder(Habit habit, DateTime reminderTime) async {
    if (reminderTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: habit.id.hashCode,
        title: 'Habit Reminder: ${habit.name}',
        body: habit.description,
        scheduledTime: reminderTime,
        payload: 'habit_${habit.id}',
      );
    }
  }

  // Schedule debt payment reminder
  Future<void> scheduleDebtReminder(Debt debt) async {
    if (debt.dueDate.isAfter(DateTime.now()) && !debt.isPaid) {
      // Schedule 1 day before due date
      final reminderTime = debt.dueDate.subtract(const Duration(days: 1));
      
      if (reminderTime.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: debt.id.hashCode,
          title: 'Debt Payment Due: ${debt.person}',
          body: '${formatMoney(debt.amount)} due tomorrow',
          scheduledTime: reminderTime,
          payload: 'debt_${debt.id}',
        );
      }
    }
  }

  // Schedule goal deadline reminder
  Future<void> scheduleGoalReminder(Goal goal) async {
    if (goal.deadline.isAfter(DateTime.now()) && !goal.isCompleted) {
      // Schedule 3 days before deadline
      final reminderTime = goal.deadline.subtract(const Duration(days: 3));
      
      if (reminderTime.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: goal.id.hashCode,
          title: 'Goal Deadline Approaching: ${goal.title}',
          body: '3 days remaining',
          scheduledTime: reminderTime,
          payload: 'goal_${goal.id}',
        );
      }
    }
  }

  // Schedule water reminder (every 2 hours during day)
  Future<void> scheduleWaterReminders() async {
    final now = DateTime.now();
    
    for (int hour = 8; hour <= 20; hour += 2) {
      var reminderTime = DateTime(now.year, now.month, now.day, hour);
      
      if (reminderTime.isBefore(now)) {
        reminderTime = reminderTime.add(const Duration(days: 1));
      }
      
      await scheduleNotification(
        id: 1000 + hour,
        title: '💧 Water Reminder',
        body: 'Time to drink water! Stay hydrated.',
        scheduledTime: reminderTime,
        payload: 'water',
      );
    }
  }

  // Schedule all active reminders
  Future<void> scheduleAllReminders() async {
    final reminderBox = Hive.box<Reminder>('reminders');
    
    for (var reminder in reminderBox.values) {
      if (reminder.isEnabled && reminder.reminderTime.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: reminder.id.hashCode,
          title: reminder.title,
          body: reminder.description,
          scheduledTime: reminder.reminderTime,
          payload: 'reminder_${reminder.id}',
        );
      }
    }
  }
}
