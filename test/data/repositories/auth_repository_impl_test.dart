import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_app/api/auth_api.dart';
import 'package:shop_app/data/repositories/auth_repository_impl.dart';
import 'package:shop_app/models/auth_response.dart';
import 'package:shop_app/models/registration_response.dart';

class MockAuthApi extends Mock implements AuthApi {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthApi mockApi;

  setUp(() {
    mockApi = MockAuthApi();
    repository = AuthRepositoryImpl(mockApi);
  });

  group('AuthRepositoryImpl', () {
    group('login', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      final mockAuthResponse = AuthResponse(
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
        user: null,
      );

      test('should successfully login with valid credentials', () async {
        // Arrange
        when(() => mockApi.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockAuthResponse);

        // Act
        final result = await repository.login(testEmail, testPassword);

        // Assert
        expect(result, equals(mockAuthResponse));
        verify(() => mockApi.login(email: testEmail, password: testPassword))
            .called(1);
      });

      test('should sanitize email before login', () async {
        // Arrange
        const emailWithSpaces = '  test@example.com  ';
        when(() => mockApi.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockAuthResponse);

        // Act
        await repository.login(emailWithSpaces, testPassword);

        // Assert
        verify(() => mockApi.login(email: testEmail, password: testPassword))
            .called(1);
      });

      test('should propagate API errors', () async {
        // Arrange
        when(() => mockApi.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Invalid credentials'));

        // Act & Assert
        expect(
          () => repository.login(testEmail, testPassword),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('registerBuyer', () {
      const testEmail = 'test@example.com';
      const testPhone = '+77001234567';
      const testPassword = 'password123';
      final mockResponse = RegistrationResponse(
        message: 'Registration successful',
        success: true,
      );

      test('should successfully register buyer', () async {
        // Arrange
        when(() => mockApi.registerBuyer(
              email: any(named: 'email'),
              phone: any(named: 'phone'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.registerBuyer(
          email: testEmail,
          phone: testPhone,
          password: testPassword,
        );

        // Assert
        expect(result, equals(mockResponse));
        verify(() => mockApi.registerBuyer(
              email: testEmail,
              phone: testPhone,
              password: testPassword,
            )).called(1);
      });

      test('should sanitize inputs before registration', () async {
        // Arrange
        const emailWithSpaces = '  test@example.com  ';
        const phoneWithSpaces = '  +77001234567  ';
        when(() => mockApi.registerBuyer(
              email: any(named: 'email'),
              phone: any(named: 'phone'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockResponse);

        // Act
        await repository.registerBuyer(
          email: emailWithSpaces,
          phone: phoneWithSpaces,
          password: testPassword,
        );

        // Assert
        verify(() => mockApi.registerBuyer(
              email: testEmail,
              phone: testPhone,
              password: testPassword,
            )).called(1);
      });
    });

    group('refreshToken', () {
      const testRefreshToken = 'refresh_token';
      final mockAuthResponse = AuthResponse(
        accessToken: 'new_access_token',
        refreshToken: 'new_refresh_token',
        user: null,
      );

      test('should successfully refresh token', () async {
        // Arrange
        when(() => mockApi.refreshToken(testRefreshToken))
            .thenAnswer((_) async => mockAuthResponse);

        // Act
        final result = await repository.refreshToken(testRefreshToken);

        // Assert
        expect(result, equals(mockAuthResponse));
        verify(() => mockApi.refreshToken(testRefreshToken)).called(1);
      });

      test('should propagate refresh errors', () async {
        // Arrange
        when(() => mockApi.refreshToken(testRefreshToken))
            .thenThrow(Exception('Token expired'));

        // Act & Assert
        expect(
          () => repository.refreshToken(testRefreshToken),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('logout', () {
      const testRefreshToken = 'refresh_token';

      test('should successfully logout', () async {
        // Arrange
        when(() => mockApi.logout(testRefreshToken))
            .thenAnswer((_) async => {});

        // Act
        await repository.logout(testRefreshToken);

        // Assert
        verify(() => mockApi.logout(testRefreshToken)).called(1);
      });

      test('should propagate logout errors', () async {
        // Arrange
        when(() => mockApi.logout(testRefreshToken))
            .thenThrow(Exception('Logout failed'));

        // Act & Assert
        expect(
          () => repository.logout(testRefreshToken),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
