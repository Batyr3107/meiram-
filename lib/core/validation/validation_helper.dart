import 'package:shop_app/core/error/app_error.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/validators/validators.dart';

/// Validation Helper
///
/// Provides reusable validation methods that throw exceptions on validation errors.
/// This eliminates code duplication in Use Cases.
///
/// Usage:
/// ```dart
/// ValidationHelper.requireValidEmail(email); // Throws ValidationError if invalid
/// ValidationHelper.requireValidPassword(password); // Throws ValidationError if invalid
/// ```
class ValidationHelper {
  ValidationHelper._(); // Private constructor to prevent instantiation

  /// Validates email and throws ValidationError.invalidEmail() if invalid
  ///
  /// Throws: [ValidationError] if email is invalid
  static void requireValidEmail(String email) {
    final String? error = Validators.email(email);
    if (error != null) {
      AppLogger.warning('Validation failed: Invalid email');
      throw ValidationError.invalidEmail();
    }
  }

  /// Validates password and throws ValidationError.passwordTooShort() if invalid
  ///
  /// Throws: [ValidationError] if password is invalid
  static void requireValidPassword(String password) {
    final String? error = Validators.password(password);
    if (error != null) {
      AppLogger.warning('Validation failed: $error');
      throw ValidationError.passwordTooShort();
    }
  }

  /// Validates phone number and throws ArgumentError if invalid
  ///
  /// Throws: [ArgumentError] if phone is invalid
  static void requireValidPhone(String phone) {
    final String? error = Validators.phone(phone);
    if (error != null) {
      AppLogger.warning('Validation failed: Invalid phone');
      throw ArgumentError('Некорректный телефон');
    }
  }

  /// Validates that a string is not empty
  ///
  /// Throws: [ArgumentError] if string is empty
  static void requireNonEmpty(String value, String fieldName) {
    if (value.trim().isEmpty) {
      AppLogger.warning('Validation failed: $fieldName is empty');
      throw ArgumentError('$fieldName не может быть пустым');
    }
  }

  /// Validates that a value is positive
  ///
  /// Throws: [ArgumentError] if value is not positive
  static void requirePositive(num value, String fieldName) {
    if (value <= 0) {
      AppLogger.warning('Validation failed: $fieldName must be positive');
      throw ArgumentError('$fieldName должно быть положительным числом');
    }
  }

  /// Validates minimum length
  ///
  /// Throws: [ArgumentError] if length is less than minimum
  static void requireMinLength(String value, int minLength, String fieldName) {
    if (value.length < minLength) {
      AppLogger.warning('Validation failed: $fieldName too short');
      throw ArgumentError('$fieldName должно содержать минимум $minLength символов');
    }
  }

  /// Validates maximum length
  ///
  /// Throws: [ArgumentError] if length exceeds maximum
  static void requireMaxLength(String value, int maxLength, String fieldName) {
    if (value.length > maxLength) {
      AppLogger.warning('Validation failed: $fieldName too long');
      throw ArgumentError('$fieldName должно содержать максимум $maxLength символов');
    }
  }

  /// Validates that value is within range
  ///
  /// Throws: [ArgumentError] if value is outside range
  static void requireInRange(num value, num min, num max, String fieldName) {
    if (value < min || value > max) {
      AppLogger.warning('Validation failed: $fieldName out of range');
      throw ArgumentError('$fieldName должно быть в диапазоне от $min до $max');
    }
  }
}
