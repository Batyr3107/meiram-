import 'package:dio/dio.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/services/auth_service.dart';

/// Authentication Interceptor
///
/// Automatically adds authentication headers to all outgoing requests:
/// - Authorization: Bearer {access_token}
/// - X-User-Id: {user_id}
///
/// Usage:
/// ```dart
/// final client = DioClient();
/// client.dio.interceptors.add(AuthInterceptor());
/// ```
class AuthInterceptor extends Interceptor {
  /// Include User-Id header in requests
  final bool includeUserId;

  /// Constructor
  AuthInterceptor({this.includeUserId = true});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Ensure auth service is loaded
      await AuthService.ensureLoaded();

      // Add Authorization header
      final String? token = AuthService.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        AppLogger.debug('AuthInterceptor: Added Authorization header');
      } else {
        AppLogger.warning('AuthInterceptor: No access token available');
      }

      // Add User-Id header if enabled
      if (includeUserId) {
        final String? userId = AuthService.userId;
        if (userId != null && userId.isNotEmpty) {
          options.headers['X-User-Id'] = userId;
          AppLogger.debug('AuthInterceptor: Added X-User-Id header');
        } else {
          AppLogger.warning('AuthInterceptor: No user ID available');
        }
      }
    } catch (e) {
      AppLogger.error('AuthInterceptor: Failed to add auth headers', e);
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log authentication errors
    if (err.response?.statusCode == 401) {
      AppLogger.warning('AuthInterceptor: Unauthorized request (401)');
    } else if (err.response?.statusCode == 403) {
      AppLogger.warning('AuthInterceptor: Forbidden request (403)');
    }

    handler.next(err);
  }
}

/// Simple Auth Interceptor without User-Id header
///
/// Use this for APIs that don't require User-Id header.
class SimpleAuthInterceptor extends AuthInterceptor {
  SimpleAuthInterceptor() : super(includeUserId: false);
}
