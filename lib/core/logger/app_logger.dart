import 'package:logger/logger.dart';

/// Production-grade logger with different log levels
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: Level.debug,
  );

  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log API request
  static void apiRequest(String method, String url, {dynamic data}) {
    _logger.i(
      '🌐 API Request: $method $url',
      error: data != null ? 'Data: $data' : null,
    );
  }

  /// Log API response
  static void apiResponse(
    String method,
    String url,
    int statusCode, {
    dynamic data,
  }) {
    final String emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    _logger.i(
      '$emoji API Response: $method $url ($statusCode)',
      error: data != null ? 'Data: $data' : null,
    );
  }

  /// Log navigation
  static void navigation(String from, String to) {
    _logger.d('📍 Navigation: $from → $to');
  }

  /// Log user action
  static void userAction(String action, {Map<String, dynamic>? params}) {
    _logger.i('👤 User Action: $action', error: params);
  }
}
