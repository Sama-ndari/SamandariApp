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
import 'package:samapp/screens/settings_screen.dart';
import 'package:samapp/screens/pomodoro_screen.dart';
import 'package:samapp/screens/ai_hub_screen.dart';
import 'package:samapp/services/hive_service.dart';
import 'package:samapp/services/notification_service.dart';
import 'package:samapp/theme/theme.dart';
import 'package:samapp/services/theme_service.dart';
import 'package:samapp/services/capsule_check_service.dart';
import 'package:samapp/services/auto_backup_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:samapp/models/habit.dart';
import 'package:samapp/models/legacy_capsule.dart';
import 'package:samapp/services/recurring_task_service.dart';
import 'package:samapp/services/navigation_service.dart'; // This is the missing import
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math' as math;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); 
  await HiveService.init();
  await Hive.openBox<String>('dashboard_names');
  final themeService = ThemeService();
  await themeService.init();
  
  // Check for recurring tasks
  final recurringTaskService = RecurringTaskService();
  await recurringTaskService.checkAndCreateRecurringTasks();
  
  // Initialize auto backup
  final autoBackupService = AutoBackupService();
  await autoBackupService.init();
  await autoBackupService.performAutoBackup();
  
  // Perform capsule check on startup
  await CapsuleCheckService().checkAndSendCapsules();
  
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
            navigatorKey: NavigationService.navigatorKey, // Assigning the global key
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

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver, TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }


  int _selectedIndex = 0;
  bool _isMenuOpen = false;
  late AnimationController _animationController;
  final TextEditingController _passwordController = TextEditingController();

  final List<Widget> _screens = [
    TasksScreen(),
    ExpensesScreen(),
    NotesScreen(),
    WaterScreen(),
    HabitsScreen(),
    DebtsScreen(),
    SoulSyncScreen(),
    GoalsScreen(),
  ];

  void _onItemTapped(int index) async {
    if (index == 4) {
      if (_isMenuOpen) {
        setState(() {
          _animationController.reverse();
          _isMenuOpen = false;
        });
      } else {
        final bool passwordCorrect = await _showPasswordDialog() ?? false;
        if (passwordCorrect) {
          setState(() {
            _isMenuOpen = true;
            _animationController.forward();
          });
        }
      }
    } else {
      setState(() {
        _selectedIndex = index;
        if (_isMenuOpen) {
          _animationController.reverse();
          _isMenuOpen = false;
        }
      });
    }
  }

  void _onMenuItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _animationController.reverse();
      _isMenuOpen = false;
    });
  }

  Future<bool?> _showPasswordDialog() async {
    String? errorText;
    _passwordController.clear();

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.lock_outline),
                  SizedBox(width: 10),
                  Text('Enter Password'),
                ],
              ),
              content: TextField(
                controller: _passwordController,
                obscureText: true,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  errorText: errorText,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                ElevatedButton(
                  child: const Text('Submit'),
                  onPressed: () {
                    if (_passwordController.text == 'sam') {
                      Navigator.of(context).pop(true);
                    } else {
                      setState(() {
                        errorText = 'Incorrect Password';
                      });
                      _passwordController.clear();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
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
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AiHubScreen(),
                ),
              );
            },
            tooltip: 'AI Hub',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'calendar') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CalendarScreen()),
                );
              } else if (value == 'contacts') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ContactsScreen(),
                  ),
                );
              } else if (value == 'pomodoro') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PomodoroScreen(),
                  ),
                );
              } else if (value == 'ai_hub') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AiHubScreen(),
                  ),
                );
              } else if (value == 'settings') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              } else if (value == 'theme') {
                Provider.of<ThemeService>(context, listen: false).toggleTheme();
              }
            },
            itemBuilder: (BuildContext context) {
              final themeProvider = Provider.of<ThemeService>(context, listen: false);
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'contacts',
                  child: ListTile(
                    leading: Icon(Icons.contacts_outlined),
                    title: Text('Contacts'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'calendar',
                  child: ListTile(
                    leading: Icon(Icons.calendar_month_outlined),
                    title: Text('Calendar'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'pomodoro',
                  child: ListTile(
                    leading: Icon(Icons.timer_outlined),
                    title: Text('Pomodoro Timer'),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings_outlined),
                    title: Text('Settings'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'theme',
                  child: ListTile(
                    leading: Icon(
                      themeProvider.isDarkMode 
                        ? Icons.light_mode 
                        : Icons.dark_mode,
                    ),
                    title: Text(
                      themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                    ),
                  ),
                ),
              ];
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          // Circular Menu Items
          if (_isMenuOpen)
            ...[
              _buildAnimatedMenuItem(index: 0, angle: 90, targetIndex: 4, icon: Icons.repeat),
              _buildAnimatedMenuItem(index: 1, angle: 60, targetIndex: 5, icon: Icons.money_off),
              _buildAnimatedMenuItem(index: 2, angle: 30, targetIndex: 6, icon: Icons.self_improvement),
              _buildAnimatedMenuItem(index: 3, angle: 0, targetIndex: 7, icon: Icons.flag),
            ],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Tasks'),
          const BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Expenses'),
          const BottomNavigationBarItem(icon: Icon(Icons.note_outlined), label: 'Notes'),
          const BottomNavigationBarItem(icon: Icon(Icons.local_drink), label: 'Water'),
          BottomNavigationBarItem(
            icon: Icon(_isMenuOpen ? Icons.close : Icons.more_horiz),
            label: 'More',
          ),
        ],
        currentIndex: _selectedIndex < 4 ? _selectedIndex : 4,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index, required String label}) {
    return IconButton(
      icon: Icon(
        icon,
        color: _selectedIndex == index ? Theme.of(context).colorScheme.primary : Colors.grey,
      ),
      onPressed: () => _onItemTapped(index),
      tooltip: label,
    );
  }

  Widget _buildCircularMenuItem({required IconData icon, required VoidCallback onPressed}) {
    return FloatingActionButton(
      onPressed: onPressed,
      mini: true,
      child: Icon(icon, color: Colors.white),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildAnimatedMenuItem({required int index, required double angle, required int targetIndex, required IconData icon}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final radius = 100.0 * _animationController.value;
        final radians = angle * (math.pi / 180.0);
        return Positioned(
          bottom: 80 + radius * math.sin(radians),
          right: 16 + radius * math.cos(radians),
          child: _buildCircularMenuItem(icon: icon, onPressed: () => _onMenuItemTapped(targetIndex)),
        );
      },
    );
  }
}
