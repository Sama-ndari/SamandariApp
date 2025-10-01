import 'package:flutter/material.dart';
import 'package:samapp/services/notification_service.dart';
import 'package:samapp/widgets/in_app_notification.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _waterRemindersEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Colors.green,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Notifications Enabled',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'You will receive reminders for tasks, habits, and more',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Water Reminders
          Card(
            child: SwitchListTile(
              title: const Text('Water Reminders'),
              subtitle: const Text('Every 2 hours (8am - 8pm)'),
              secondary: const Icon(Icons.water_drop, color: Colors.blue),
              value: _waterRemindersEnabled,
              onChanged: (value) async {
                setState(() {
                  _waterRemindersEnabled = value;
                });
                
                if (value) {
                  await _notificationService.scheduleWaterReminders();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Water reminders enabled'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  // Cancel water reminders (IDs 1008-1020)
                  for (int hour = 8; hour <= 20; hour += 2) {
                    await _notificationService.cancelNotification(1000 + hour);
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Water reminders disabled'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // In-App Notification Demos
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'In-App Notifications (WhatsApp Style)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Beautiful notifications that appear at the top of the screen',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          NotificationType.success(
                            context,
                            title: 'Success!',
                            message: 'Task completed successfully',
                          );
                        },
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Success'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          NotificationType.error(
                            context,
                            title: 'Error!',
                            message: 'Something went wrong',
                          );
                        },
                        icon: const Icon(Icons.error, size: 18),
                        label: const Text('Error'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          NotificationType.warning(
                            context,
                            title: 'Warning!',
                            message: 'Please check your input',
                          );
                        },
                        icon: const Icon(Icons.warning, size: 18),
                        label: const Text('Warning'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          NotificationType.info(
                            context,
                            title: 'Info',
                            message: 'Here is some useful information',
                          );
                        },
                        icon: const Icon(Icons.info, size: 18),
                        label: const Text('Info'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          NotificationType.taskReminder(
                            context,
                            taskTitle: 'Complete project presentation',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Task tapped!')),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.task_alt, size: 18),
                        label: const Text('Task'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          NotificationType.waterReminder(context);
                        },
                        icon: const Icon(Icons.local_drink, size: 18),
                        label: const Text('Water'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          NotificationType.habitReminder(
                            context,
                            habitTitle: 'Morning meditation',
                          );
                        },
                        icon: const Icon(Icons.repeat, size: 18),
                        label: const Text('Habit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Test Notification
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.purple),
              title: const Text('System Notification Test'),
              subtitle: const Text('Test if system notifications are working'),
              trailing: ElevatedButton(
                onPressed: () async {
                  // Show immediate notification
                  await _notificationService.scheduleNotification(
                    id: 9999,
                    title: '🎉 Test Notification',
                    body: 'Notifications are working perfectly!',
                    scheduledTime: DateTime.now().add(const Duration(seconds: 1)),
                  );
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Test notification sent! Check your notification tray.'),
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text('Test'),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Notification Types Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Automatic Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationInfo(
                    Icons.task_alt,
                    'Tasks',
                    '1 hour before due date',
                    Colors.blue,
                  ),
                  const Divider(),
                  _buildNotificationInfo(
                    Icons.repeat,
                    'Habits',
                    'At scheduled reminder time',
                    Colors.purple,
                  ),
                  const Divider(),
                  _buildNotificationInfo(
                    Icons.money_off,
                    'Debts',
                    '1 day before due date',
                    Colors.red,
                  ),
                  const Divider(),
                  _buildNotificationInfo(
                    Icons.flag,
                    'Goals',
                    '3 days before deadline',
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Clear All Notifications
          Card(
            color: Colors.red.withOpacity(0.1),
            child: ListTile(
              leading: const Icon(Icons.clear_all, color: Colors.red),
              title: const Text(
                'Clear All Notifications',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Cancel all scheduled notifications'),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Notifications?'),
                    content: const Text(
                      'This will cancel all scheduled notifications. You can re-enable them anytime.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  await _notificationService.cancelAllNotifications();
                  setState(() {
                    _waterRemindersEnabled = false;
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All notifications cleared'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationInfo(
    IconData icon,
    String title,
    String timing,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  timing,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }
}
