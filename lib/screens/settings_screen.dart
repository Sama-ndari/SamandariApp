import 'package:flutter/material.dart';
import 'package:samapp/screens/backup_restore_screen.dart';
import 'package:samapp/screens/notification_settings_screen.dart';
import 'package:samapp/screens/demo_ui_screen.dart';
import 'package:samapp/screens/dashboard_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Backup & Restore'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const BackupRestoreScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_none_outlined),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('UI Widgets Demo'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const DemoUIScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dashboard_customize_outlined),
            title: const Text('Customize Dashboard Names'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const DashboardSettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
