import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/presentation/widgets/theme_toggle_button.dart';
import 'package:shop_app/presentation/providers/theme_provider.dart';

void main() {
  group('ThemeToggleButton', () {
    testWidgets('should display light mode icon when in dark mode',
        (tester) async {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Set dark mode
      final notifier = container.read(themeModeProvider.notifier);
      notifier.state = ThemeMode.dark;

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: const [ThemeToggleButton()],
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode), findsNothing);
    });

    testWidgets('should display dark mode icon when in light mode',
        (tester) async {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Set light mode
      final notifier = container.read(themeModeProvider.notifier);
      notifier.state = ThemeMode.light;

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: const [ThemeToggleButton()],
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      expect(find.byIcon(Icons.light_mode), findsNothing);
    });

    testWidgets('should have correct tooltip in dark mode', (tester) async {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeModeProvider.notifier);
      notifier.state = ThemeMode.dark;

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: const [ThemeToggleButton()],
              ),
            ),
          ),
        ),
      );

      // Assert
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.tooltip, 'Светлая тема');
    });

    testWidgets('should have correct tooltip in light mode', (tester) async {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeModeProvider.notifier);
      notifier.state = ThemeMode.light;

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: const [ThemeToggleButton()],
              ),
            ),
          ),
        ),
      );

      // Assert
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.tooltip, 'Темная тема');
    });

    testWidgets('should toggle theme when tapped', (tester) async {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeModeProvider.notifier);
      notifier.state = ThemeMode.light;

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: const [ThemeToggleButton()],
              ),
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);

      // Tap the button
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Assert
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    testWidgets('should be tappable and accessible', (tester) async {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: const [ThemeToggleButton()],
              ),
            ),
          ),
        ),
      );

      // Assert
      final iconButton = find.byType(IconButton);
      expect(iconButton, findsOneWidget);

      // Verify it's enabled
      final widget = tester.widget<IconButton>(iconButton);
      expect(widget.onPressed, isNotNull);
    });
  });
}
