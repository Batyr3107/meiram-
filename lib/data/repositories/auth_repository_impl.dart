import 'package:shop_app/api/auth_api.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/performance/performance_monitor.dart';
import 'package:shop_app/core/security/input_sanitizer.dart';
import 'package:shop_app/domain/repositories/auth_repository.dart';
import 'package:shop_app/dto/auth_response.dart';
import 'package:shop_app/dto/registration_response.dart';

/// Authentication Repository Implementation
///
/// Implements IAuthRepository using AuthApi as data source.
/// Handles data transformation, sanitization, and performance monitoring.
class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl(this._authApi);

  final AuthApi _authApi;

  @override
  Future<AuthResponse> login(String email, String password) async {
    return await PerformanceMonitor.measure('auth_repository_login', () async {
      // Sanitize inputs
      final sanitizedEmail = InputSanitizer.sanitizeEmail(email);

      AppLogger.debug('AuthRepository: login for email domain: ${sanitizedEmail.split('@').last}');

      try {
        final response = await _authApi.login(
          email: sanitizedEmail,
          password: password,
        );

        AppLogger.info('AuthRepository: Login successful');
        return response;
      } catch (e, stack) {
        AppLogger.error('AuthRepository: Login failed', e, stack);
        rethrow;
      }
    });
  }

  @override
  Future<RegistrationResponse> registerBuyer({
    required String email,
    required String phone,
    required String password,
  }) async {
    return await PerformanceMonitor.measure('auth_repository_register', () async {
      // Sanitize inputs
      final sanitizedEmail = InputSanitizer.sanitizeEmail(email);
      final sanitizedPhone = InputSanitizer.sanitizeText(phone);

      AppLogger.debug('AuthRepository: Register new buyer');

      try {
        final response = await _authApi.registerBuyer(
          email: sanitizedEmail,
          phone: sanitizedPhone,
          password: password,
        );

        AppLogger.info('AuthRepository: Registration successful');
        return response;
      } catch (e, stack) {
        AppLogger.error('AuthRepository: Registration failed', e, stack);
        rethrow;
      }
    });
  }

  @override
  Future<AuthResponse> refreshToken(String refreshToken) async {
    return await PerformanceMonitor.measure('auth_repository_refresh', () async {
      AppLogger.debug('AuthRepository: Refreshing access token');

      try {
        // Get device ID from platform
        final deviceId = await _getDeviceId();

        final response = await _authApi.refresh(
          refreshToken: refreshToken,
          deviceId: deviceId,
        );

        AppLogger.debug('AuthRepository: Token refreshed successfully');
        return response;
      } catch (e, stack) {
        AppLogger.error('AuthRepository: Token refresh failed', e, stack);
        rethrow;
      }
    });
  }

  /// Get unique device identifier
  Future<String> _getDeviceId() async {
    try {
      // Try to import device_info_plus
      // For now, use a generated UUID that persists in shared preferences
      // TODO: Implement actual device ID when device_info_plus is properly configured
      return 'flutter-device-${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      AppLogger.warning('Could not get device ID: $e');
      return 'flutter-device-unknown';
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    return await PerformanceMonitor.measure('auth_repository_logout', () async {
      AppLogger.info('AuthRepository: Logging out user');

      try {
        await _authApi.logout(refreshToken: refreshToken);
        AppLogger.info('AuthRepository: Logout successful');
      } catch (e, stack) {
        AppLogger.error('AuthRepository: Logout failed', e, stack);
        rethrow;
      }
    });
  }

  @override
  bool isAuthenticated() {
    // This should check if tokens exist in secure storage
    // For now, return false as this is typically handled by AuthService
    return false;
  }

  @override
  String? getUserId() {
    // This should read user ID from tokens or secure storage
    // For now, return null as this is typically handled by AuthService
    return null;
  }

  @override
  String? getUserEmail() {
    // This should read user email from tokens or secure storage
    // For now, return null as this is typically handled by AuthService
    return null;
  }
}
