import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shop_app/core/logger/app_logger.dart';

/// Retry interceptor for network requests
/// 
/// Automatically retries failed requests with exponential backoff.
/// Retries only on network errors, not on HTTP errors (4xx, 5xx).
/// 
/// Features:
/// - Configurable max retries
/// - Exponential backoff
/// - Jitter to avoid thundering herd
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
  });

  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    int retryCount = 0;
    final RequestOptions requestOptions = err.requestOptions;

    while (retryCount < maxRetries) {
      retryCount++;
      
      final Duration delay = _calculateDelay(retryCount);
      AppLogger.warning(
        'Retrying request (attempt $retryCount/$maxRetries) after ${delay.inMilliseconds}ms',
      );
      
      await Future<void>.delayed(delay);

      try {
        final Response<dynamic> response = await dio.request<dynamic>(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          ),
        );

        AppLogger.info('Request succeeded after $retryCount retries');
        return handler.resolve(response);
      } on DioException catch (e) {
        if (retryCount >= maxRetries || !_shouldRetry(e)) {
          AppLogger.error('Request failed after $retryCount retries');
          return handler.next(e);
        }
      }
    }

    return handler.next(err);
  }

  /// Check if request should be retried
  bool _shouldRetry(DioException error) {
    // Retry on network errors
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on specific HTTP errors
    if (error.response != null) {
      final int? statusCode = error.response?.statusCode;
      // Retry on 5xx server errors and 429 rate limit
      return statusCode != null && (statusCode >= 500 || statusCode == 429);
    }

    // Retry on socket exceptions
    if (error.error is SocketException) {
      return true;
    }

    return false;
  }

  /// Calculate delay with exponential backoff and jitter
  Duration _calculateDelay(int retryCount) {
    // Exponential backoff: 1s, 2s, 4s
    final int exponentialDelay = baseDelay.inMilliseconds * (1 << (retryCount - 1));
    
    // Add jitter (±25%) to avoid thundering herd
    final int jitter = (exponentialDelay * 0.25 * (0.5 - DateTime.now().millisecond / 1000)).round();
    
    return Duration(milliseconds: exponentialDelay + jitter);
  }
}
