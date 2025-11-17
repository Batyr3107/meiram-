import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/presentation/providers/auth_provider.dart';
import 'package:shop_app/models/auth_response.dart';

void main() {
  group('AuthState', () {
    test('should have correct initial values', () {
      // Arrange & Act
      const state = AuthState();

      // Assert
      expect(state.isAuthenticated, false);
      expect(state.isLoading, false);
      expect(state.user, null);
      expect(state.error, null);
    });

    test('should correctly copy state with new values', () {
      // Arrange
      const initialState = AuthState();
      final user = AuthResponse(
        accessToken: 'token',
        refreshToken: 'refresh',
        user: null,
      );

      // Act
      final newState = initialState.copyWith(
        isAuthenticated: true,
        isLoading: true,
        user: user,
        error: 'Test error',
      );

      // Assert
      expect(newState.isAuthenticated, true);
      expect(newState.isLoading, true);
      expect(newState.user, user);
      expect(newState.error, 'Test error');
    });

    test('should preserve unchanged values in copyWith', () {
      // Arrange
      const initialState = AuthState(
        isAuthenticated: true,
        isLoading: false,
      );

      // Act
      final newState = initialState.copyWith(error: 'New error');

      // Assert
      expect(newState.isAuthenticated, true);
      expect(newState.isLoading, false);
      expect(newState.error, 'New error');
    });
  });

  group('AuthStateNotifier', () {
    late AuthStateNotifier notifier;

    setUp(() {
      notifier = AuthStateNotifier();
    });

    test('should start with unauthenticated state', () {
      // Assert
      expect(notifier.state.isAuthenticated, false);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.user, null);
      expect(notifier.state.error, null);
    });

    test('should set authenticated state correctly', () {
      // Arrange
      final user = AuthResponse(
        accessToken: 'token',
        refreshToken: 'refresh',
        user: null,
      );

      // Act
      notifier.setAuthenticated(user);

      // Assert
      expect(notifier.state.isAuthenticated, true);
      expect(notifier.state.user, user);
      expect(notifier.state.error, null);
    });

    test('should set loading state correctly', () {
      // Act
      notifier.setLoading(true);

      // Assert
      expect(notifier.state.isLoading, true);

      // Act
      notifier.setLoading(false);

      // Assert
      expect(notifier.state.isLoading, false);
    });

    test('should set error correctly', () {
      // Act
      notifier.setError('Test error');

      // Assert
      expect(notifier.state.error, 'Test error');
      expect(notifier.state.isLoading, false);
    });

    test('should clear state on logout', () {
      // Arrange
      final user = AuthResponse(
        accessToken: 'token',
        refreshToken: 'refresh',
        user: null,
      );
      notifier.setAuthenticated(user);

      // Act
      notifier.logout();

      // Assert
      expect(notifier.state.isAuthenticated, false);
      expect(notifier.state.user, null);
      expect(notifier.state.error, null);
    });

    test('should clear error when setting authenticated', () {
      // Arrange
      notifier.setError('Previous error');
      final user = AuthResponse(
        accessToken: 'token',
        refreshToken: 'refresh',
        user: null,
      );

      // Act
      notifier.setAuthenticated(user);

      // Assert
      expect(notifier.state.error, null);
      expect(notifier.state.isAuthenticated, true);
    });
  });
}
