import 'package:flutter/material.dart';

/// Responsive Design Helper
/// Provides adaptive sizing, spacing, and breakpoints for different screen sizes
class ResponsiveHelper {
  // Private constructor
  ResponsiveHelper._();

  /// Breakpoints for different device sizes
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Check if device is mobile (width < 600)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if device is small mobile (width < 360)
  static bool isSmallMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  /// Check if device is tablet (600 <= width < 1200)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Check if device is desktop (width >= 1200)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Adaptive spacing based on screen size
  /// Returns smaller spacing on small screens, larger on big screens
  static double spacing(BuildContext context, double base) {
    final width = screenWidth(context);
    if (width < 360) return base * 0.75; // 75% on very small screens
    if (width >= tabletBreakpoint) return base * 1.25; // 125% on tablets
    if (width >= desktopBreakpoint) return base * 1.5; // 150% on desktop
    return base; // 100% on normal mobile
  }

  /// Adaptive font size based on screen size
  static double fontSize(BuildContext context, double base) {
    final width = screenWidth(context);
    if (width < 360) return base * 0.9; // 90% on very small screens
    if (width >= tabletBreakpoint) return base * 1.1; // 110% on tablets
    if (width >= desktopBreakpoint) return base * 1.2; // 120% on desktop
    return base; // 100% on normal mobile
  }

  /// Adaptive icon size based on screen size
  static double iconSize(BuildContext context, double base) {
    final width = screenWidth(context);
    if (width < 360) return base * 0.8; // 80% on very small screens
    if (width >= tabletBreakpoint) return base * 1.2; // 120% on tablets
    if (width >= desktopBreakpoint) return base * 1.4; // 140% on desktop
    return base; // 100% on normal mobile
  }

  /// Adaptive padding - returns EdgeInsets scaled to screen size
  static EdgeInsets adaptivePadding(BuildContext context, EdgeInsets base) {
    final factor = _getScaleFactor(context);
    return EdgeInsets.only(
      left: base.left * factor,
      top: base.top * factor,
      right: base.right * factor,
      bottom: base.bottom * factor,
    );
  }

  /// Adaptive width - percentage of screen width with min/max constraints
  static double adaptiveWidth(
    BuildContext context, {
    required double percentage,
    double? min,
    double? max,
  }) {
    final width = screenWidth(context) * (percentage / 100);
    if (min != null && width < min) return min;
    if (max != null && width > max) return max;
    return width;
  }

  /// Adaptive height - percentage of screen height with min/max constraints
  static double adaptiveHeight(
    BuildContext context, {
    required double percentage,
    double? min,
    double? max,
  }) {
    final height = screenHeight(context) * (percentage / 100);
    if (min != null && height < min) return min;
    if (max != null && height > max) return max;
    return height;
  }

  /// Get responsive value based on screen size
  /// Example: ResponsiveHelper.value(context, mobile: 2, tablet: 3, desktop: 4)
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  /// Get scale factor for current screen size
  static double _getScaleFactor(BuildContext context) {
    final width = screenWidth(context);
    if (width < 360) return 0.75;
    if (width >= tabletBreakpoint) return 1.25;
    if (width >= desktopBreakpoint) return 1.5;
    return 1.0;
  }

  /// Grid column count based on screen size
  static int gridColumns(BuildContext context, {int mobile = 2, int tablet = 3, int desktop = 4}) {
    return value(context, mobile: mobile, tablet: tablet, desktop: desktop);
  }

  /// Get text theme with responsive sizes
  static TextTheme responsiveTextTheme(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final factor = _getScaleFactor(context);

    return TextTheme(
      displayLarge: theme.displayLarge?.copyWith(fontSize: (theme.displayLarge?.fontSize ?? 57) * factor),
      displayMedium: theme.displayMedium?.copyWith(fontSize: (theme.displayMedium?.fontSize ?? 45) * factor),
      displaySmall: theme.displaySmall?.copyWith(fontSize: (theme.displaySmall?.fontSize ?? 36) * factor),
      headlineLarge: theme.headlineLarge?.copyWith(fontSize: (theme.headlineLarge?.fontSize ?? 32) * factor),
      headlineMedium: theme.headlineMedium?.copyWith(fontSize: (theme.headlineMedium?.fontSize ?? 28) * factor),
      headlineSmall: theme.headlineSmall?.copyWith(fontSize: (theme.headlineSmall?.fontSize ?? 24) * factor),
      titleLarge: theme.titleLarge?.copyWith(fontSize: (theme.titleLarge?.fontSize ?? 22) * factor),
      titleMedium: theme.titleMedium?.copyWith(fontSize: (theme.titleMedium?.fontSize ?? 16) * factor),
      titleSmall: theme.titleSmall?.copyWith(fontSize: (theme.titleSmall?.fontSize ?? 14) * factor),
      bodyLarge: theme.bodyLarge?.copyWith(fontSize: (theme.bodyLarge?.fontSize ?? 16) * factor),
      bodyMedium: theme.bodyMedium?.copyWith(fontSize: (theme.bodyMedium?.fontSize ?? 14) * factor),
      bodySmall: theme.bodySmall?.copyWith(fontSize: (theme.bodySmall?.fontSize ?? 12) * factor),
      labelLarge: theme.labelLarge?.copyWith(fontSize: (theme.labelLarge?.fontSize ?? 14) * factor),
      labelMedium: theme.labelMedium?.copyWith(fontSize: (theme.labelMedium?.fontSize ?? 12) * factor),
      labelSmall: theme.labelSmall?.copyWith(fontSize: (theme.labelSmall?.fontSize ?? 11) * factor),
    );
  }

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  /// Get safe padding (accounts for notches, status bar, etc.)
  static EdgeInsets safePadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get available screen height (minus keyboard and safe areas)
  static double availableHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom -
        mediaQuery.viewInsets.bottom;
  }
}
