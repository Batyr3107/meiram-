import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/validators/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('returns error for empty email', () {
        expect(Validators.email(''), isNotNull);
        expect(Validators.email(null), isNotNull);
      });

      test('returns error for invalid email format', () {
        expect(Validators.email('invalid'), isNotNull);
        expect(Validators.email('test@'), isNotNull);
        expect(Validators.email('@test.com'), isNotNull);
      });

      test('returns null for valid email', () {
        expect(Validators.email('test@example.com'), isNull);
      });
    });

    group('password', () {
      test('returns error for short password', () {
        expect(Validators.password('12345'), isNotNull);
      });

      test('returns null for valid password', () {
        expect(Validators.password('123456'), isNull);
      });
    });

    group('phone', () {
      test('returns null for valid Kazakhstan phone', () {
        expect(Validators.phone('77001234567'), isNull);
        expect(Validators.phone('+7 700 123 45 67'), isNull);
      });
    });
  });
}
