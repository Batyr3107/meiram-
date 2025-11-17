/// Input sanitization utilities
/// 
/// Protects against XSS, SQL injection, and other attacks
/// by sanitizing user input before processing.
/// 
/// Usage:
/// ```dart
/// final safe = InputSanitizer.sanitizeText(userInput);
/// final safeEmail = InputSanitizer.sanitizeEmail(email);
/// ```
class InputSanitizer {
  /// Sanitize general text input
  /// 
  /// Removes potentially harmful characters and patterns
  static String sanitizeText(String input) {
    if (input.isEmpty) {
      return input;
    }

    String sanitized = input.trim();
    
    // Remove null bytes
    sanitized = sanitized.replaceAll('\u0000', '');
    
    // Remove control characters except newline and tab
    sanitized = sanitized.replaceAll(
      RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'),
      '',
    );
    
    // Escape HTML-like tags
    sanitized = _escapeHtml(sanitized);
    
    return sanitized;
  }

  /// Sanitize email input
  static String sanitizeEmail(String email) {
    String sanitized = email.trim().toLowerCase();
    
    // Remove any characters not allowed in emails
    sanitized = sanitized.replaceAll(
      RegExp(r'[^a-z0-9@._+-]'),
      '',
    );
    
    return sanitized;
  }

  /// Sanitize phone number
  static String sanitizePhone(String phone) {
    // Keep only digits, +, and spaces
    return phone.replaceAll(RegExp(r'[^\d+\s()-]'), '');
  }

  /// Sanitize numeric input
  static String sanitizeNumeric(String input) {
    // Keep only digits and decimal point
    return input.replaceAll(RegExp(r'[^\d.]'), '');
  }

  /// Escape HTML characters
  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }

  /// Validate and sanitize URL
  static String? sanitizeUrl(String url) {
    try {
      final Uri uri = Uri.parse(url);
      
      // Only allow http and https
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        return null;
      }
      
      return uri.toString();
    } catch (e) {
      return null;
    }
  }

  /// Remove SQL injection patterns
  static String sanitizeSql(String input) {
    String sanitized = input;
    
    // Remove common SQL injection patterns
    final List<String> sqlPatterns = <String>[
      r"'",
      r'"',
      r'--',
      r'/*',
      r'*/',
      r'xp_',
      r'sp_',
      r'exec',
      r'execute',
      r'select',
      r'insert',
      r'update',
      r'delete',
      r'drop',
      r'create',
      r'alter',
      r'union',
      r'or 1=1',
      r'or true',
    ];
    
    for (final String pattern in sqlPatterns) {
      sanitized = sanitized.replaceAll(
        RegExp(pattern, caseSensitive: false),
        '',
      );
    }
    
    return sanitized;
  }

  /// Limit string length
  static String limitLength(String input, int maxLength) {
    if (input.length <= maxLength) {
      return input;
    }
    return input.substring(0, maxLength);
  }

  /// Remove leading/trailing whitespace and normalize spaces
  static String normalizeWhitespace(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
