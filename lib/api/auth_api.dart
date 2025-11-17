import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/network/dio_client.dart';
import 'package:shop_app/dto/auth_response.dart';
import 'package:shop_app/dto/registration_response.dart';

/// Authentication API client
///
/// Handles all authentication-related API calls:
/// - User registration
/// - Login
/// - Token refresh
/// - Logout
///
/// Uses [DioClient] for network requests with automatic retry logic.
class AuthApi {
  AuthApi() : _client = DioClient();

  final DioClient _client;

  /// Register new buyer
  ///
  /// Returns [RegistrationResponse] with userId and role.
  ///
  /// Example:
  /// ```dart
  /// final response = await authApi.registerBuyer(
  ///   email: 'user@example.com',
  ///   phone: '+77001234567',
  ///   password: 'securePassword123',
  /// );
  /// ```
  Future<RegistrationResponse> registerBuyer({
    required String email,
    required String phone,
    required String password,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'role': 'BUYER',
      'email': email,
      'phone': phone,
      'password': password,
    };

    AppLogger.info('Registering new buyer: $email');

    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/auth/register',
        data: body,
      );

      if (response.data == null) {
        throw Exception('Empty response from server');
      }

      AppLogger.info('Registration successful for: $email');
      return RegistrationResponse.fromJson(response.data!);
    } catch (e, stack) {
      AppLogger.error('Registration failed for: $email', e, stack);
      rethrow;
    }
  }

  /// Login with email and password
  ///
  /// Returns [AuthResponse] with access and refresh tokens.
  ///
  /// Example:
  /// ```dart
  /// final response = await authApi.login(
  ///   email: 'user@example.com',
  ///   password: 'password123',
  /// );
  /// ```
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'username': email,
      'password': password,
      'deviceId': 'flutter-${DateTime.now().millisecondsSinceEpoch}',
    };

    AppLogger.info('Login attempt for: $email');

    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/auth/login',
        data: body,
      );

      if (response.data == null) {
        throw Exception('Empty response from server');
      }

      AppLogger.info('Login successful for: $email');
      return AuthResponse.fromJson(response.data!);
    } catch (e, stack) {
      AppLogger.error('Login failed for: $email', e, stack);
      rethrow;
    }
  }

  /// Refresh access token using refresh token
  ///
  /// Returns new [AuthResponse] with fresh tokens.
  Future<AuthResponse> refresh({
    required String refreshToken,
    required String deviceId,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'refreshToken': refreshToken,
      'deviceId': deviceId,
    };

    AppLogger.debug('Refreshing access token');

    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: body,
      );

      if (response.data == null) {
        throw Exception('Empty response from server');
      }

      AppLogger.debug('Token refresh successful');
      return AuthResponse.fromJson(response.data!);
    } catch (e, stack) {
      AppLogger.error('Token refresh failed', e, stack);
      rethrow;
    }
  }

  /// Logout and invalidate refresh token
  Future<void> logout({required String refreshToken}) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'refreshToken': refreshToken,
    };

    AppLogger.info('Logging out user');

    try {
      await _client.post<void>('/auth/logout', data: body);
      AppLogger.info('Logout successful');
    } catch (e, stack) {
      AppLogger.error('Logout failed', e, stack);
      rethrow;
    }
  }
}