import 'package:dio/dio.dart';
import 'package:shop_app/core/error/app_error.dart';
import 'package:shop_app/core/logger/app_logger.dart';

/// Core Error Handler - Domain layer
///
/// Handles error conversion and logging without UI dependencies.
/// For UI-related error handling, use UIErrorHandler from presentation layer.
class ErrorHandler {
  /// Handle error and convert to AppError
  static AppError handleError(Object error, [StackTrace? stackTrace]) {
    AppLogger.error('Error occurred', error, stackTrace);

    if (error is AppError) {
      return error;
    }

    if (error is DioException) {
      return NetworkError.fromDioException(error);
    }

    return UnknownError.fromException(error);
  }

  /// Check if error is recoverable (can be retried)
  static bool isRecoverable(Object error) {
    if (error is NetworkError) {
      return error.isRetryable;
    }
    return false;
  }

  /// Get user-friendly error message
  static String getUserMessage(Object error) {
    final appError = handleError(error);
    return appError.message;
  }

  /// Check if error requires authentication
  static bool requiresAuthentication(Object error) {
    if (error is AuthError) {
      return true;
    }
    if (error is DioException) {
      return error.response?.statusCode == 401;
    }
    return false;
  }
}
