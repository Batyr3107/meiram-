import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/security/input_sanitizer.dart';

void main() {
  group('InputSanitizer', () {
    group('sanitizeEmail', () {
      test('converts to lowercase', () {
        final String result = InputSanitizer.sanitizeEmail('TEST@EXAMPLE.COM');
        expect(result, 'test@example.com');
      });

      test('trims whitespace', () {
        final String result = InputSanitizer.sanitizeEmail('  test@example.com  ');
        expect(result, 'test@example.com');
      });
    });

    group('sanitizePhone', () {
      test('keeps only valid phone characters', () {
        final String result = InputSanitizer.sanitizePhone('+7 (700) 123-45-67');
        expect(result, '+7 (700) 123-45-67');
      });
    });

    group('limitLength', () {
      test('truncates long strings', () {
        final String result = InputSanitizer.limitLength('hello world', 5);
        expect(result, 'hello');
      });
    });
  });
}
