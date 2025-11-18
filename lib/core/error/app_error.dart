import 'package:dio/dio.dart';

/// Base class for all application errors
abstract class AppError implements Exception {
  const AppError(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AppError: $message${code != null ? ' ($code)' : ''}';
}

/// Network-related errors
class NetworkError extends AppError {
  const NetworkError(super.message, {super.code});

  /// Check if this error can be retried
  bool get isRetryable {
    // Timeout errors and connection errors are retryable
    if (code == 'CONNECTION_TIMEOUT' ||
        code == 'SEND_TIMEOUT' ||
        code == 'RECEIVE_TIMEOUT' ||
        code == 'CONNECTION_ERROR') {
      return true;
    }

    // Server errors (500+) are retryable
    if (code != null && code!.startsWith('HTTP_5')) {
      return true;
    }

    // 429 (Too Many Requests) is retryable after delay
    if (code == 'HTTP_429') {
      return true;
    }

    // Client errors (400-499) are generally not retryable
    return false;
  }

  factory NetworkError.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const NetworkError(
          'Превышено время ожидания подключения',
          code: 'CONNECTION_TIMEOUT',
        );
      case DioExceptionType.sendTimeout:
        return const NetworkError(
          'Превышено время ожидания отправки',
          code: 'SEND_TIMEOUT',
        );
      case DioExceptionType.receiveTimeout:
        return const NetworkError(
          'Превышено время ожидания ответа',
          code: 'RECEIVE_TIMEOUT',
        );
      case DioExceptionType.badResponse:
        final int? statusCode = error.response?.statusCode;
        return NetworkError(
          _getMessageForStatusCode(statusCode),
          code: 'HTTP_$statusCode',
        );
      case DioExceptionType.cancel:
        return const NetworkError('Запрос отменен', code: 'CANCELLED');
      case DioExceptionType.connectionError:
        return const NetworkError(
          'Ошибка подключения к серверу',
          code: 'CONNECTION_ERROR',
        );
      default:
        return NetworkError(
          'Неизвестная ошибка сети: ${error.message}',
          code: 'UNKNOWN',
        );
    }
  }

  static String _getMessageForStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Неверный запрос';
      case 401:
        return 'Необходима авторизация';
      case 403:
        return 'Доступ запрещен';
      case 404:
        return 'Ресурс не найден';
      case 409:
        return 'Конфликт данных';
      case 422:
        return 'Ошибка валидации';
      case 429:
        return 'Слишком много запросов';
      case 500:
        return 'Внутренняя ошибка сервера';
      case 502:
        return 'Сервер недоступен';
      case 503:
        return 'Сервис временно недоступен';
      default:
        return 'Ошибка сервера (код: $statusCode)';
    }
  }
}

/// Authentication errors
class AuthError extends AppError {
  const AuthError(super.message, {super.code});

  factory AuthError.invalidCredentials() => const AuthError(
        'Неверный email или пароль',
        code: 'INVALID_CREDENTIALS',
      );

  factory AuthError.tokenExpired() => const AuthError(
        'Сессия истекла. Пожалуйста, войдите снова',
        code: 'TOKEN_EXPIRED',
      );

  factory AuthError.userNotFound() => const AuthError(
        'Пользователь не найден',
        code: 'USER_NOT_FOUND',
      );

  factory AuthError.emailAlreadyExists() => const AuthError(
        'Пользователь с таким email уже существует',
        code: 'EMAIL_EXISTS',
      );
}

/// Validation errors
class ValidationError extends AppError {
  const ValidationError(super.message, {super.code, this.field});

  final String? field;

  factory ValidationError.required(String field) => ValidationError(
        'Поле "$field" обязательно для заполнения',
        code: 'REQUIRED',
        field: field,
      );

  factory ValidationError.invalidEmail() => const ValidationError(
        'Неверный формат email',
        code: 'INVALID_EMAIL',
        field: 'email',
      );

  factory ValidationError.invalidPhone() => const ValidationError(
        'Неверный формат телефона',
        code: 'INVALID_PHONE',
        field: 'phone',
      );

  factory ValidationError.passwordTooShort() => const ValidationError(
        'Пароль должен содержать минимум 6 символов',
        code: 'PASSWORD_TOO_SHORT',
        field: 'password',
      );

  factory ValidationError.custom(String message, {String? field}) =>
      ValidationError(message, code: 'CUSTOM', field: field);
}

/// Business logic errors
class BusinessLogicError extends AppError {
  const BusinessLogicError(super.message, {super.code});

  factory BusinessLogicError.cartEmpty() => const BusinessLogicError(
        'Корзина пуста',
        code: 'CART_EMPTY',
      );

  factory BusinessLogicError.insufficientStock() => const BusinessLogicError(
        'Недостаточно товара на складе',
        code: 'INSUFFICIENT_STOCK',
      );

  factory BusinessLogicError.minOrderAmount(double amount) =>
      BusinessLogicError(
        'Минимальная сумма заказа: $amount ₸',
        code: 'MIN_ORDER_AMOUNT',
      );
}

/// Cache errors
class CacheError extends AppError {
  const CacheError(super.message, {super.code});

  factory CacheError.readFailed() => const CacheError(
        'Не удалось прочитать данные из кэша',
        code: 'READ_FAILED',
      );

  factory CacheError.writeFailed() => const CacheError(
        'Не удалось записать данные в кэш',
        code: 'WRITE_FAILED',
      );
}

/// Unknown/Unhandled errors
class UnknownError extends AppError {
  const UnknownError(super.message, {super.code});

  factory UnknownError.fromException(Object error) => UnknownError(
        'Неизвестная ошибка: ${error.toString()}',
        code: 'UNKNOWN',
      );
}
