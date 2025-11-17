import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_app/domain/repositories/auth_repository.dart';
import 'package:shop_app/domain/usecases/register_buyer_usecase.dart';
import 'package:shop_app/models/registration_response.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterBuyerUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterBuyerUseCase(mockRepository);
  });

  group('RegisterBuyerUseCase', () {
    const testEmail = 'test@example.com';
    const testPhone = '+77001234567';
    const testPassword = 'SecurePass123!';

    final mockResponse = RegistrationResponse(
      message: 'Registration successful',
      success: true,
    );

    test('should successfully register buyer with valid credentials', () async {
      // Arrange
      when(() => mockRepository.registerBuyer(
            email: any(named: 'email'),
            phone: any(named: 'phone'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await useCase.execute(
        email: testEmail,
        phone: testPhone,
        password: testPassword,
      );

      // Assert
      expect(result, equals(mockResponse));
      verify(() => mockRepository.registerBuyer(
            email: testEmail,
            phone: testPhone,
            password: testPassword,
          )).called(1);
    });

    test('should throw ArgumentError for invalid email', () async {
      // Arrange
      const invalidEmail = 'not-an-email';

      // Act & Assert
      expect(
        () => useCase.execute(
          email: invalidEmail,
          phone: testPhone,
          password: testPassword,
        ),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(() => mockRepository.registerBuyer(
            email: any(named: 'email'),
            phone: any(named: 'phone'),
            password: any(named: 'password'),
          ));
    });

    test('should throw ArgumentError for invalid phone', () async {
      // Arrange
      const invalidPhone = '123'; // Too short

      // Act & Assert
      expect(
        () => useCase.execute(
          email: testEmail,
          phone: invalidPhone,
          password: testPassword,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw ArgumentError for invalid password', () async {
      // Arrange
      const invalidPassword = '123'; // Too short

      // Act & Assert
      expect(
        () => useCase.execute(
          email: testEmail,
          phone: testPhone,
          password: invalidPassword,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should sanitize email before registration', () async {
      // Arrange
      const emailWithSpaces = '  test@example.com  ';
      when(() => mockRepository.registerBuyer(
            email: any(named: 'email'),
            phone: any(named: 'phone'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockResponse);

      // Act
      await useCase.execute(
        email: emailWithSpaces,
        phone: testPhone,
        password: testPassword,
      );

      // Assert
      verify(() => mockRepository.registerBuyer(
            email: testEmail, // Should be trimmed
            phone: any(named: 'phone'),
            password: any(named: 'password'),
          )).called(1);
    });
  });
}
