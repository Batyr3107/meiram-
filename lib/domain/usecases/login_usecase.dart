import 'package:shop_app/core/error/app_error.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/performance/performance_monitor.dart';
import 'package:shop_app/core/security/input_sanitizer.dart';
import 'package:shop_app/core/validation/validation_helper.dart';
import 'package:shop_app/domain/repositories/auth_repository.dart';
import 'package:shop_app/dto/auth_response.dart';

/// Login use case
/// 
/// Encapsulates business logic for user login.
/// Validates input, sanitizes data, and handles authentication.
/// 
/// Benefits:
/// - Single Responsibility: only handles login logic
/// - Testable: easily mockable repository
/// - Reusable: can be used from multiple UI layers
/// 
/// Usage:
/// ```dart
/// final useCase = LoginUseCase(authRepository);
/// try {
///   final response = await useCase.execute(email, password);
///   // Handle success
/// } on ValidationError catch (e) {
///   // Handle validation error
/// } on AuthError catch (e) {
///   // Handle auth error
/// }
/// ```
class LoginUseCase {
  LoginUseCase(this._authRepository);

  final IAuthRepository _authRepository;

  Future<AuthResponse> execute(String email, String password) async {
    return PerformanceMonitor.measure('login_usecase', () async {
      // Validate input using ValidationHelper
      ValidationHelper.requireValidEmail(email);
      ValidationHelper.requireValidPassword(password);

      // Sanitize input
      final String sanitizedEmail = InputSanitizer.sanitizeEmail(email);
      final String sanitizedPassword = password.trim();

      AppLogger.info('Attempting login for: $sanitizedEmail');

      try {
        final AuthResponse response = await _authRepository.login(
          sanitizedEmail,
          sanitizedPassword,
        );

        AppLogger.info('Login successful for: $sanitizedEmail');
        return response;
      } catch (e) {
        AppLogger.error('Login failed for: $sanitizedEmail', e);
        rethrow;
      }
    });
  }
}
