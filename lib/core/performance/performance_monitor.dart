import 'package:flutter/foundation.dart';
import 'package:shop_app/core/logger/app_logger.dart';

/// Performance monitoring utility
/// 
/// Tracks execution time of operations and reports slow operations.
/// 
/// Usage:
/// ```dart
/// final monitor = PerformanceMonitor.start('database_query');
/// // ... perform operation
/// monitor.stop(); // Logs if operation took too long
/// 
/// // Or use with callback
/// await PerformanceMonitor.measure('api_call', () async {
///   return await api.fetchData();
/// });
/// ```
class PerformanceMonitor {
  PerformanceMonitor._(this.operationName, this._startTime);

  factory PerformanceMonitor.start(String operationName) {
    final Stopwatch stopwatch = Stopwatch()..start();
    return PerformanceMonitor._(operationName, stopwatch);
  }

  final String operationName;
  final Stopwatch _startTime;
  bool _stopped = false;

  /// Stop monitoring and log if slow
  void stop({Duration? threshold}) {
    if (_stopped) {
      return;
    }

    _stopped = true;
    _startTime.stop();
    
    final Duration elapsed = _startTime.elapsed;
    final Duration slowThreshold = threshold ?? const Duration(milliseconds: 500);

    if (elapsed > slowThreshold) {
      AppLogger.warning(
        '⚡ Slow operation: $operationName took ${elapsed.inMilliseconds}ms',
      );
    } else if (kDebugMode) {
      AppLogger.debug(
        '⚡ $operationName completed in ${elapsed.inMilliseconds}ms',
      );
    }
  }

  /// Measure execution time of async operation
  static Future<T> measure<T>(
    String operationName,
    Future<T> Function() operation, {
    Duration? threshold,
  }) async {
    final PerformanceMonitor monitor = PerformanceMonitor.start(operationName);
    try {
      return await operation();
    } finally {
      monitor.stop(threshold: threshold);
    }
  }

  /// Measure execution time of sync operation
  static T measureSync<T>(
    String operationName,
    T Function() operation, {
    Duration? threshold,
  }) {
    final PerformanceMonitor monitor = PerformanceMonitor.start(operationName);
    try {
      return operation();
    } finally {
      monitor.stop(threshold: threshold);
    }
  }
}

/// Widget rebuild counter for optimization
/// 
/// Usage:
/// ```dart
/// class MyWidget extends StatelessWidget {
///   static final rebuilds = RebuildCounter('MyWidget');
///   
///   @override
///   Widget build(BuildContext context) {
///     rebuilds.increment();
///     return Container();
///   }
/// }
/// ```
class RebuildCounter {
  RebuildCounter(this.widgetName);

  final String widgetName;
  int _count = 0;

  void increment() {
    _count++;
    if (kDebugMode && _count % 10 == 0) {
      AppLogger.warning(
        '🔄 $widgetName has rebuilt $_count times',
      );
    }
  }

  int get count => _count;

  void reset() {
    _count = 0;
  }
}
