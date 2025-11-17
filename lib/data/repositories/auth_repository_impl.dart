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
        final response = await _authApi.refresh(
          refreshToken: refreshToken,
          deviceId: 'flutter-device', // TODO: Get from device info
        );

        AppLogger.debug('AuthRepository: Token refreshed successfully');
        return response;
      } catch (e, stack) {
        AppLogger.error('AuthRepository: Token refresh failed', e, stack);
        rethrow;
      }
    });
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
}
