import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/core/logger/app_logger.dart';

/// Theme Mode Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Theme Mode Notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadThemeMode();
  }

  static const String _themeKey = 'theme_mode';

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey);

      // Если значение не сохранено, используем светлую тему по умолчанию
      if (themeIndex == null) {
        state = ThemeMode.light;
        AppLogger.debug('Theme mode not found, using default: light');
      } else {
        state = ThemeMode.values[themeIndex];
        AppLogger.debug('Theme mode loaded: $state');
      }
    } catch (e) {
      AppLogger.error('Failed to load theme mode', e);
      // В случае ошибки всегда используем светлую тему
      state = ThemeMode.light;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
      AppLogger.info('Theme mode saved: $mode');
    } catch (e) {
      AppLogger.error('Failed to save theme mode', e);
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
