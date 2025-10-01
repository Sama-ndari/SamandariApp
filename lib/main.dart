import 'package:flutter/material.dart';
import 'package:samapp/screens/debts_screen.dart';
import 'package:samapp/screens/expenses_screen.dart';
import 'package:samapp/screens/habits_screen.dart';
import 'package:samapp/screens/notes_screen.dart';
import 'package:samapp/screens/soulsync_screen.dart';
import 'package:samapp/screens/tasks_screen.dart';
import 'package:samapp/screens/water_screen.dart';
import 'package:samapp/screens/contacts_screen.dart';
import 'package:samapp/screens/goals_screen.dart';
import 'package:samapp/screens/dashboard_screen.dart';
import 'package:samapp/screens/backup_restore_screen.dart';
import 'package:samapp/screens/statistics_screen.dart';
import 'package:samapp/screens/enhanced_analytics_screen.dart';
import 'package:samapp/screens/calendar_screen.dart';
import 'package:samapp/screens/global_search_screen.dart';
import 'package:samapp/screens/notification_settings_screen.dart';
import 'package:samapp/screens/demo_ui_screen.dart';
import 'package:samapp/services/hive_service.dart';
import 'package:samapp/services/notification_service.dart';
import 'package:samapp/theme/theme.dart';
import 'package:samapp/services/task_rollover_service.dart';
import 'package:samapp/services/theme_service.dart';
import 'package:samapp/services/recurring_task_service.dart';
import 'package:samapp/services/auto_backup_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await dotenv.load(fileName: ".env");
  final themeService = ThemeService();
  await themeService.init();
  
  // Check for recurring tasks
  final recurringTaskService = RecurringTaskService();
  await recurringTaskService.checkAndCreateRecurringTasks();
  
  // Initialize auto backup
  final autoBackupService = AutoBackupService();
  await autoBackupService.init();
  await autoBackupService.performAutoBackup();
  
  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(MyApp(themeService: themeService));
}

class MyApp extends StatelessWidget {
  final ThemeService themeService;
  
  const MyApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeService,
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'Samandari',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final TaskRolloverService _taskRolloverService = TaskRolloverService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _taskRolloverService.rolloverTasks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _taskRolloverService.rolloverTasks();
    }
  }

  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    TasksScreen(),
    ExpensesScreen(),
    NotesScreen(),
    HabitsScreen(),
    DebtsScreen(),
    WaterScreen(),
    SoulSyncScreen(),
    GoalsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Samandari'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GlobalSearchScreen(),
                ),
              );
            },
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CalendarScreen(),
                ),
              );
            },
            tooltip: 'Calendar',
          ),
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            },
            tooltip: 'Dashboard',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EnhancedAnalyticsScreen(),
                ),
              );
            },
            tooltip: 'Analytics',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'contacts') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ContactsScreen(),
                  ),
                );
              } else if (value == 'backup') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BackupRestoreScreen(),
                  ),
                );
              } else if (value == 'notifications') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                );
              } else if (value == 'ui_demo') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DemoUIScreen(),
                  ),
                );
              } else if (value == 'theme') {
                Provider.of<ThemeService>(context, listen: false).toggleTheme();
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'contacts',
                  child: ListTile(
                    leading: Icon(Icons.contacts_outlined),
                    title: Text('Contacts'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'backup',
                  child: ListTile(
                    leading: Icon(Icons.backup_outlined),
                    title: Text('Backup'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'notifications',
                  child: ListTile(
                    leading: Icon(Icons.notifications_none_outlined),
                    title: Text('Notifications'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'ui_demo',
                  child: ListTile(
                    leading: Icon(Icons.palette_outlined),
                    title: Text('UI Widgets Demo'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'theme',
                  child: ListTile(
                    leading: Icon(
                      Provider.of<ThemeService>(context, listen: false).isDarkMode 
                        ? Icons.light_mode 
                        : Icons.dark_mode,
                    ),
                    title: Text(
                      Provider.of<ThemeService>(context, listen: false).isDarkMode 
                        ? 'Light Mode' 
                        : 'Dark Mode',
                    ),
                  ),
                ),
              ];
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_outlined),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.repeat),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money_off),
            label: 'Debts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_drink),
            label: 'Water',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'SoulSync',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Goals',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
