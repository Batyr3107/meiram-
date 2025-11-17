import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/performance/performance_monitor.dart';
import 'package:shop_app/core/security/input_sanitizer.dart';
import 'package:shop_app/core/validators/validators.dart';
import 'package:shop_app/domain/repositories/auth_repository.dart';
import 'package:shop_app/dto/registration_response.dart';

/// Register Buyer Use Case
///
/// Business logic for buyer registration with validation and sanitization.
class RegisterBuyerUseCase {
  RegisterBuyerUseCase(this._authRepository);

  final IAuthRepository _authRepository;

  Future<RegistrationResponse> execute({
    required String email,
    required String phone,
    required String password,
  }) async {
    return await PerformanceMonitor.measure('register_buyer_usecase', () async {
      // Validate inputs
      final String? emailError = Validators.email(email);
      if (emailError != null) {
        AppLogger.warning('Registration failed: Invalid email');
        throw ArgumentError('Некорректный email');
      }

      final String? phoneError = Validators.phone(phone);
      if (phoneError != null) {
        AppLogger.warning('Registration failed: Invalid phone');
        throw ArgumentError('Некорректный телефон');
      }

      final String? passwordError = Validators.password(password);
      if (passwordError != null) {
        AppLogger.warning('Registration failed: Invalid password');
        throw ArgumentError(passwordError);
      }

      // Sanitize inputs
      final sanitizedEmail = InputSanitizer.sanitizeEmail(email);
      final sanitizedPhone = InputSanitizer.sanitizeText(phone);

      AppLogger.debug('RegisterBuyerUseCase: Executing registration');

      // Execute repository method
      return await _authRepository.registerBuyer(
        email: sanitizedEmail,
        phone: sanitizedPhone,
        password: password,
      );
    });
  }
}
