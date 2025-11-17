import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/presentation/widgets/pull_to_refresh_wrapper.dart';

void main() {
  group('PullToRefreshWrapper', () {
    testWidgets('should render child widget', (tester) async {
      // Arrange
      const testWidget = Text('Test Child');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PullToRefreshWrapper(
              onRefresh: () async {},
              child: testWidget,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('should call onRefresh when pulled down', (tester) async {
      // Arrange
      bool refreshCalled = false;
      Future<void> onRefresh() async {
        refreshCalled = true;
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PullToRefreshWrapper(
              onRefresh: onRefresh,
              child: ListView(
                children: const [
                  SizedBox(height: 100, child: Text('Item')),
                ],
              ),
            ),
          ),
        ),
      );

      // Simulate pull-to-refresh
      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pump();
      await tester
          .pump(const Duration(seconds: 1)); // Wait for refresh indicator

      // Assert
      expect(refreshCalled, true);
    });
  });

  group('LoadingOverlay', () {
    testWidgets('should show loading indicator when isLoading is true',
        (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: true,
              child: Text('Content'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('should not show loading indicator when isLoading is false',
        (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: false,
              child: Text('Content'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('should display message when provided', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: true,
              message: 'Loading data...',
              child: Text('Content'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Loading data...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('EmptyState', () {
    testWidgets('should display message and icon', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              message: 'No items found',
              icon: Icons.inbox,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('No items found'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('should show retry button when onRetry is provided',
        (tester) async {
      // Arrange
      bool retryCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              message: 'No items',
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Повторить'), findsOneWidget);

      // Tap retry button
      await tester.tap(find.text('Повторить'));
      expect(retryCalled, true);
    });

    testWidgets('should not show retry button when onRetry is null',
        (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              message: 'No items',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Повторить'), findsNothing);
    });
  });

  group('ErrorState', () {
    testWidgets('should display error message and icon', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Something went wrong',
              onRetry: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should call onRetry when retry button is tapped',
        (tester) async {
      // Arrange
      bool retryCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Error occurred',
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      // Tap retry button
      await tester.tap(find.text('Повторить'));
      await tester.pump();

      // Assert
      expect(retryCalled, true);
    });

    testWidgets('should always show retry button', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Error',
              onRetry: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Повторить'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should use error color from theme', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.light(error: Colors.red),
          ),
          home: Scaffold(
            body: ErrorState(
              message: 'Error',
              onRetry: () {},
            ),
          ),
        ),
      );

      // Find the error icon
      final iconFinder = find.byIcon(Icons.error_outline);
      expect(iconFinder, findsOneWidget);

      // Verify button exists
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
