import 'package:shop_app/core/logger/app_logger.dart';

/// JSON parsing utilities
///
/// Helper methods for safe parsing of JSON data with proper error handling.
class JsonParser {
  /// Safely parse DateTime from JSON value
  ///
  /// Returns current DateTime if value is null or parsing fails.
  /// Logs warning for invalid formats to aid debugging.
  ///
  /// Example:
  /// ```dart
  /// final date = JsonParser.parseDateTime(json['createdAt']);
  /// ```
  static DateTime parseDateTime(dynamic value, {DateTime? fallback}) {
    if (value == null) {
      return fallback ?? DateTime.now();
    }

    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      AppLogger.warning('Invalid date format: $value');
      return fallback ?? DateTime.now();
    }
  }

  /// Safely parse int from JSON value
  ///
  /// Returns default value if parsing fails.
  static int parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;

    if (value is int) return value;
    if (value is num) return value.toInt();

    try {
      return int.parse(value.toString());
    } catch (e) {
      AppLogger.warning('Invalid int format: $value');
      return defaultValue;
    }
  }

  /// Safely parse double from JSON value
  ///
  /// Returns default value if parsing fails.
  static double parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;

    if (value is double) return value;
    if (value is num) return value.toDouble();

    try {
      return double.parse(value.toString());
    } catch (e) {
      AppLogger.warning('Invalid double format: $value');
      return defaultValue;
    }
  }

  /// Safely parse String from JSON value
  ///
  /// Returns default value if value is null.
  static String parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// Safely parse bool from JSON value
  ///
  /// Handles various boolean representations: true, "true", 1, "1", etc.
  static bool parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;

    if (value is bool) return value;
    if (value is int) return value != 0;

    final strValue = value.toString().toLowerCase();
    if (strValue == 'true' || strValue == '1') return true;
    if (strValue == 'false' || strValue == '0') return false;

    return defaultValue;
  }

  /// Safely parse List from JSON value
  ///
  /// Returns empty list if value is null or not a List.
  static List<T> parseList<T>(
    dynamic value,
    T Function(dynamic) itemParser,
  ) {
    if (value == null) return [];
    if (value is! List) {
      AppLogger.warning('Expected List but got ${value.runtimeType}');
      return [];
    }

    try {
      return value.map((item) => itemParser(item)).toList();
    } catch (e) {
      AppLogger.error('Failed to parse list', e);
      return [];
    }
  }

  /// Validate required field exists and is not null
  ///
  /// Throws FormatException if field is missing or null.
  static T requireField<T>(Map<String, dynamic> json, String fieldName) {
    if (!json.containsKey(fieldName) || json[fieldName] == null) {
      throw FormatException('Missing required field: $fieldName');
    }
    return json[fieldName] as T;
  }

  /// Get nullable field with type safety
  ///
  /// Returns null if field doesn't exist or is wrong type.
  static T? getField<T>(Map<String, dynamic> json, String fieldName) {
    try {
      return json[fieldName] as T?;
    } catch (e) {
      AppLogger.warning(
        'Field $fieldName expected type $T but got ${json[fieldName]?.runtimeType}',
      );
      return null;
    }
  }
}
