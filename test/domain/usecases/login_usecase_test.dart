import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_app/core/error/app_error.dart';
import 'package:shop_app/domain/repositories/auth_repository.dart';
import 'package:shop_app/domain/usecases/login_usecase.dart';
import 'package:shop_app/dto/auth_response.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    const String validEmail = 'test@example.com';
    const String validPassword = 'password123';

    final AuthResponse successResponse = AuthResponse(
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
      userId: 'user_123',
      role: 'BUYER',
    );

    test('should return AuthResponse on successful login', () async {
      // Arrange
      when(() => mockRepository.login(validEmail, validPassword))
          .thenAnswer((_) async => successResponse);

      // Act
      final AuthResponse result = await useCase.execute(
        validEmail,
        validPassword,
      );

      // Assert
      expect(result, successResponse);
      verify(() => mockRepository.login(validEmail, validPassword)).called(1);
    });

    test('should throw ValidationError for invalid email', () async {
      // Act & Assert
      expect(
        () => useCase.execute('invalid_email', validPassword),
        throwsA(isA<ValidationError>()),
      );
      
      verifyNever(() => mockRepository.login(any(), any()));
    });

    test('should throw ValidationError for short password', () async {
      // Act & Assert
      expect(
        () => useCase.execute(validEmail, '123'),
        throwsA(isA<ValidationError>()),
      );
      
      verifyNever(() => mockRepository.login(any(), any()));
    });

    test('should sanitize email before calling repository', () async {
      // Arrange
      const String unsanitizedEmail = '  TEST@EXAMPLE.COM  ';
      when(() => mockRepository.login('test@example.com', validPassword))
          .thenAnswer((_) async => successResponse);

      // Act
      await useCase.execute(unsanitizedEmail, validPassword);

      // Assert
      verify(() => mockRepository.login('test@example.com', validPassword))
          .called(1);
    });

    test('should rethrow AuthError from repository', () async {
      // Arrange
      when(() => mockRepository.login(validEmail, validPassword))
          .thenThrow(AuthError.invalidCredentials());

      // Act & Assert
      expect(
        () => useCase.execute(validEmail, validPassword),
        throwsA(isA<AuthError>()),
      );
    });
  });
}
