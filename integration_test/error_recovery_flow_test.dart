import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dio/dio.dart';
import 'package:shop_app/core/error/error_handler.dart';
import 'package:shop_app/core/error/app_error.dart';

/// Integration test for error handling and recovery
///
/// Tests:
/// 1. Network error recovery
/// 2. Authentication error handling
/// 3. Validation error handling
/// 4. Retry mechanisms
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Error Recovery Flow Integration Tests', () {
    test('NetworkError isRetryable logic', () {
      // Timeout errors should be retryable
      const connectionTimeoutError = NetworkError(
        'Connection timeout',
        code: 'CONNECTION_TIMEOUT',
      );
      expect(connectionTimeoutError.isRetryable, true);

      const sendTimeoutError = NetworkError(
        'Send timeout',
        code: 'SEND_TIMEOUT',
      );
      expect(sendTimeoutError.isRetryable, true);

      // Server errors (500+) should be retryable
      const serverError = NetworkError('Server error', code: 'HTTP_500');
      expect(serverError.isRetryable, true);

      const serviceUnavailable = NetworkError(
        'Service unavailable',
        code: 'HTTP_503',
      );
      expect(serviceUnavailable.isRetryable, true);

      // Rate limit should be retryable
      const rateLimitError = NetworkError(
        'Too many requests',
        code: 'HTTP_429',
      );
      expect(rateLimitError.isRetryable, true);

      // Client errors (400-499) should NOT be retryable
      const badRequestError = NetworkError('Bad request', code: 'HTTP_400');
      expect(badRequestError.isRetryable, false);

      const unauthorizedError = NetworkError('Unauthorized', code: 'HTTP_401');
      expect(unauthorizedError.isRetryable, false);

      const notFoundError = NetworkError('Not found', code: 'HTTP_404');
      expect(notFoundError.isRetryable, false);
    });

    test('DioException to NetworkError conversion', () {
      // Connection timeout
      final connectionTimeoutException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final networkError =
          NetworkError.fromDioException(connectionTimeoutException);
      expect(networkError.code, 'CONNECTION_TIMEOUT');
      expect(networkError.isRetryable, true);

      // Bad response (401)
      final unauthorizedException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );

      final authError = NetworkError.fromDioException(unauthorizedException);
      expect(authError.code, 'HTTP_401');
      expect(authError.isRetryable, false);
    });

    test('ErrorHandler converts errors correctly', () {
      // Test AppError passthrough
      const originalError = NetworkError('Network error', code: 'NET_ERROR');
      final handledError = ErrorHandler.handleError(originalError);
      expect(handledError, equals(originalError));

      // Test DioException conversion
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );
      final convertedError = ErrorHandler.handleError(dioException);
      expect(convertedError, isA<NetworkError>());
      expect(convertedError.code, 'CONNECTION_ERROR');

      // Test unknown error conversion
      final unknownException = Exception('Unknown error');
      final unknownError = ErrorHandler.handleError(unknownException);
      expect(unknownError, isA<UnknownError>());
      expect(unknownError.code, 'UNKNOWN');
    });

    test('isRecoverable checks error retry capability', () {
      // Retryable network errors
      const timeoutError = NetworkError(
        'Timeout',
        code: 'CONNECTION_TIMEOUT',
      );
      expect(ErrorHandler.isRecoverable(timeoutError), true);

      // Non-retryable errors
      const authError = AuthError('Auth failed', code: 'INVALID_CREDENTIALS');
      expect(ErrorHandler.isRecoverable(authError), false);

      const validationError = ValidationError('Invalid input', code: 'INVALID');
      expect(ErrorHandler.isRecoverable(validationError), false);
    });

    test('requiresAuthentication detects auth errors', () {
      // Auth error
      final authError = AuthError.tokenExpired();
      expect(ErrorHandler.requiresAuthentication(authError), true);

      // 401 DioException
      final unauthorizedException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );
      expect(
          ErrorHandler.requiresAuthentication(unauthorizedException), true);

      // Other errors
      const networkError = NetworkError('Network error', code: 'NET_ERROR');
      expect(ErrorHandler.requiresAuthentication(networkError), false);
    });

    test('getUserMessage provides user-friendly messages', () {
      // Network error
      const networkError = NetworkError(
        'Connection timeout',
        code: 'CONNECTION_TIMEOUT',
      );
      final message = ErrorHandler.getUserMessage(networkError);
      expect(message, contains('timeout'));

      // Auth error
      final authError = AuthError.invalidCredentials();
      final authMessage = ErrorHandler.getUserMessage(authError);
      expect(authMessage, contains('email'));

      // Validation error
      final validationError = ValidationError.invalidEmail();
      final validationMessage = ErrorHandler.getUserMessage(validationError);
      expect(validationMessage, contains('email'));
    });

    test('Error recovery flow simulation', () async {
      // Simulate a retryable error scenario
      int attemptCount = 0;
      const maxRetries = 3;

      Future<String> fetchDataWithRetry() async {
        while (attemptCount < maxRetries) {
          try {
            attemptCount++;

            // Simulate network error on first 2 attempts
            if (attemptCount < 3) {
              throw const NetworkError(
                'Connection timeout',
                code: 'CONNECTION_TIMEOUT',
              );
            }

            // Success on 3rd attempt
            return 'Success data';
          } catch (error) {
            if (attemptCount >= maxRetries) {
              rethrow;
            }

            // Check if error is retryable
            if (!ErrorHandler.isRecoverable(error)) {
              rethrow;
            }

            // Exponential backoff
            await Future.delayed(
              Duration(milliseconds: 100 * attemptCount),
            );
          }
        }

        throw const NetworkError('Max retries reached', code: 'MAX_RETRIES');
      }

      // Execute
      final result = await fetchDataWithRetry();

      // Verify
      expect(result, equals('Success data'));
      expect(attemptCount, equals(3));
    });

    test('Non-retryable errors fail immediately', () async {
      // Simulate non-retryable error (auth error)
      Future<String> fetchDataWithNonRetryableError() async {
        throw AuthError.invalidCredentials();
      }

      // Should fail immediately without retry
      expect(
        () => fetchDataWithNonRetryableError(),
        throwsA(isA<AuthError>()),
      );
    });

    test('Error logging does not throw', () {
      // Verify error handling logs errors but doesn't throw
      expect(() {
        try {
          throw Exception('Test exception');
        } catch (e, stack) {
          ErrorHandler.handleError(e, stack);
        }
      }, returnsNormally);
    });

    test('Error code extraction and categorization', () {
      // Test various error codes
      final errors = <AppError>[
        const NetworkError('Timeout', code: 'CONNECTION_TIMEOUT'),
        const NetworkError('Server error', code: 'HTTP_500'),
        const NetworkError('Not found', code: 'HTTP_404'),
        AuthError.invalidCredentials(),
        ValidationError.invalidEmail(),
        BusinessLogicError.cartEmpty(),
        CacheError.readFailed(),
      ];

      for (final error in errors) {
        expect(error.code, isNotNull);
        expect(error.message, isNotEmpty);
      }
    });
  });
}
