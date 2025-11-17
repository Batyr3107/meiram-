import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/presentation/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeModeNotifier', () {
    late ThemeModeNotifier notifier;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should start with system theme mode', () async {
      // Act
      notifier = ThemeModeNotifier();
      await notifier.loadThemeMode();

      // Assert
      expect(notifier.state, ThemeMode.system);
      expect(notifier.isDarkMode, false);
    });

    test('should load saved dark theme from preferences', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'isDarkMode': true});
      notifier = ThemeModeNotifier();

      // Act
      await notifier.loadThemeMode();

      // Assert
      expect(notifier.state, ThemeMode.dark);
      expect(notifier.isDarkMode, true);
    });

    test('should load saved light theme from preferences', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'isDarkMode': false});
      notifier = ThemeModeNotifier();

      // Act
      await notifier.loadThemeMode();

      // Assert
      expect(notifier.state, ThemeMode.light);
      expect(notifier.isDarkMode, false);
    });

    test('should toggle from light to dark theme', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'isDarkMode': false});
      notifier = ThemeModeNotifier();
      await notifier.loadThemeMode();

      // Act
      await notifier.toggleTheme();

      // Assert
      expect(notifier.state, ThemeMode.dark);
      expect(notifier.isDarkMode, true);

      // Verify persistence
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isDarkMode'), true);
    });

    test('should toggle from dark to light theme', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'isDarkMode': true});
      notifier = ThemeModeNotifier();
      await notifier.loadThemeMode();

      // Act
      await notifier.toggleTheme();

      // Assert
      expect(notifier.state, ThemeMode.light);
      expect(notifier.isDarkMode, false);

      // Verify persistence
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isDarkMode'), false);
    });

    test('should persist theme changes', () async {
      // Arrange
      notifier = ThemeModeNotifier();
      await notifier.loadThemeMode();

      // Act
      await notifier.toggleTheme();
      await notifier.toggleTheme();
      await notifier.toggleTheme();

      // Assert
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isDarkMode'), true);
      expect(notifier.isDarkMode, true);
    });

    test('should handle missing preferences gracefully', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      notifier = ThemeModeNotifier();

      // Act
      await notifier.loadThemeMode();

      // Assert
      expect(notifier.state, ThemeMode.system);
      expect(notifier.isDarkMode, false);
    });
  });
}
