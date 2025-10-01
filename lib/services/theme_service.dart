import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  late Box _settingsBox;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  Future<void> init() async {
    _settingsBox = await Hive.openBox('settings');
    final savedTheme = _settingsBox.get(_themeKey, defaultValue: 'light');
    _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _settingsBox.put(_themeKey, _themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;
}
