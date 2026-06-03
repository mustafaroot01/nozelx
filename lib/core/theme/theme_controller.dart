import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';

/// Theme Controller for managing light/dark mode
/// Supports system theme detection and manual toggle with persistence

enum ThemeModeOption { system, light, dark }

class ThemeController with ChangeNotifier {
  ThemeModeOption _themeMode = ThemeModeOption.light;
  bool _isInitialized = false;

  ThemeModeOption get themeMode => _themeMode;
  bool get isDarkMode {
    if (!_isInitialized) return false;
    switch (_themeMode) {
      case ThemeModeOption.system:
        return SchedulerBinding
                .instance
                .platformDispatcher
                .platformBrightness ==
            Brightness.dark;
      case ThemeModeOption.light:
        return false;
      case ThemeModeOption.dark:
        return true;
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme_mode');

    if (savedTheme != null) {
      _themeMode = ThemeModeOption.values.firstWhere(
        (mode) => mode.toString() == savedTheme,
        orElse: () => ThemeModeOption.light,
      );
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeModeOption mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.toString());
  }

  Future<void> toggleDarkMode() async {
    final newMode = isDarkMode ? ThemeModeOption.light : ThemeModeOption.dark;
    await setThemeMode(newMode);
  }

  ThemeMode getThemeMode() {
    switch (_themeMode) {
      case ThemeModeOption.system:
        return ThemeMode.system;
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
    }
  }
}
