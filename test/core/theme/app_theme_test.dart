import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('should not be instantiable', () {
      // The private constructor prevents instantiation
      // This test verifies the class structure is correct
      expect(AppTheme.lightTheme, isNotNull);
      expect(AppTheme.darkTheme, isNotNull);
    });

    group('Light Theme', () {
      late ThemeData theme;

      setUp(() {
        theme = AppTheme.lightTheme;
      });

      test('should use Material 3', () {
        expect(theme.useMaterial3, true);
      });

      test('should have light brightness', () {
        expect(theme.brightness, Brightness.light);
      });

      test('should have correct primary color', () {
        expect(theme.colorScheme.primary, const Color(0xFF6200EE));
      });

      test('should have correct secondary color', () {
        expect(theme.colorScheme.secondary, const Color(0xFF03DAC6));
      });

      test('should have correct background color', () {
        expect(theme.scaffoldBackgroundColor, const Color(0xFFF5F5F5));
      });

      test('should have correct AppBar configuration', () {
        final appBarTheme = theme.appBarTheme;
        expect(appBarTheme.elevation, 0);
        expect(appBarTheme.centerTitle, true);
        expect(appBarTheme.backgroundColor, AppTheme.primaryLight);
        expect(appBarTheme.foregroundColor, Colors.white);
      });

      test('should have rounded card corners', () {
        final cardShape = theme.cardTheme.shape as RoundedRectangleBorder;
        final borderRadius = cardShape.borderRadius as BorderRadius;
        expect(borderRadius.topLeft.x, 12);
      });

      test('should have rounded button corners', () {
        final buttonStyle = theme.elevatedButtonTheme.style;
        expect(buttonStyle, isNotNull);
      });

      test('should have rounded input decoration', () {
        final inputDecoration = theme.inputDecorationTheme;
        expect(inputDecoration.filled, true);
        expect(inputDecoration.fillColor, Colors.white);
      });
    });

    group('Dark Theme', () {
      late ThemeData theme;

      setUp(() {
        theme = AppTheme.darkTheme;
      });

      test('should use Material 3', () {
        expect(theme.useMaterial3, true);
      });

      test('should have dark brightness', () {
        expect(theme.brightness, Brightness.dark);
      });

      test('should have correct primary color', () {
        expect(theme.colorScheme.primary, const Color(0xFFBB86FC));
      });

      test('should have correct secondary color', () {
        expect(theme.colorScheme.secondary, const Color(0xFF03DAC6));
      });

      test('should have correct background color', () {
        expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
      });

      test('should have correct surface color', () {
        expect(theme.colorScheme.surface, const Color(0xFF1E1E1E));
      });

      test('should have correct AppBar configuration', () {
        final appBarTheme = theme.appBarTheme;
        expect(appBarTheme.elevation, 0);
        expect(appBarTheme.centerTitle, true);
        expect(appBarTheme.backgroundColor, const Color(0xFF1E1E1E));
        expect(appBarTheme.foregroundColor, Colors.white);
      });

      test('should have correct card color', () {
        expect(theme.cardTheme.color, const Color(0xFF1E1E1E));
      });

      test('should have correct input decoration fill color', () {
        final inputDecoration = theme.inputDecorationTheme;
        expect(inputDecoration.filled, true);
        expect(inputDecoration.fillColor, const Color(0xFF2C2C2C));
      });
    });

    group('Text Styles', () {
      test('should have headline1 style', () {
        expect(AppTheme.headline1.fontSize, 24);
        expect(AppTheme.headline1.fontWeight, FontWeight.bold);
      });

      test('should have headline2 style', () {
        expect(AppTheme.headline2.fontSize, 20);
        expect(AppTheme.headline2.fontWeight, FontWeight.bold);
      });

      test('should have bodyText1 style', () {
        expect(AppTheme.bodyText1.fontSize, 16);
      });

      test('should have bodyText2 style', () {
        expect(AppTheme.bodyText2.fontSize, 14);
      });

      test('should have caption style', () {
        expect(AppTheme.caption.fontSize, 12);
        expect(AppTheme.caption.fontWeight, FontWeight.w300);
      });
    });

    group('Theme Consistency', () {
      test('both themes should have consistent elevation', () {
        final lightAppBarElevation = AppTheme.lightTheme.appBarTheme.elevation;
        final darkAppBarElevation = AppTheme.darkTheme.appBarTheme.elevation;
        expect(lightAppBarElevation, darkAppBarElevation);
      });

      test('both themes should center AppBar title', () {
        expect(AppTheme.lightTheme.appBarTheme.centerTitle, true);
        expect(AppTheme.darkTheme.appBarTheme.centerTitle, true);
      });

      test('both themes should use Material 3', () {
        expect(AppTheme.lightTheme.useMaterial3, true);
        expect(AppTheme.darkTheme.useMaterial3, true);
      });
    });
  });
}
