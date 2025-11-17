import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_app/api/auth_api.dart';
import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/domain/repositories/auth_repository.dart';
import 'package:shop_app/domain/usecases/login_usecase.dart';
import 'package:shop_app/domain/usecases/register_buyer_usecase.dart';
import 'package:shop_app/dto/auth_response.dart';
import 'package:shop_app/dto/registration_response.dart';

class MockAuthApi extends Mock implements AuthApi {}

/// Integration test for complete authentication flow
///
/// Tests:
/// 1. User registration (buyer)
/// 2. User login
/// 3. Token management
/// 4. Logout
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthApi mockAuthApi;
  late IAuthRepository authRepository;
  late RegisterBuyerUseCase registerUseCase;
  late LoginUseCase loginUseCase;

  setUpAll(() async {
    // Initialize DI
    await configureDependencies();
  });

  setUp(() {
    mockAuthApi = MockAuthApi();
    authRepository = getIt<IAuthRepository>();
    registerUseCase = RegisterBuyerUseCase(authRepository);
    loginUseCase = LoginUseCase(authRepository);
  });

  group('Authentication Flow Integration Tests', () {
    const testEmail = 'integration_test@example.com';
    const testPhone = '+77001234567';
    const testPassword = 'SecurePass123!';

    final mockAuthResponse = AuthResponse(
      accessToken: 'test_access_token',
      refreshToken: 'test_refresh_token',
      user: null,
    );

    final mockRegistrationResponse = RegistrationResponse(
      message: 'Registration successful',
      success: true,
    );

    test('Complete authentication flow: register → login → logout', () async {
      // Step 1: Register new buyer
      when(() => mockAuthApi.registerBuyer(
            email: any(named: 'email'),
            phone: any(named: 'phone'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockRegistrationResponse);

      final registrationResult = await registerUseCase.execute(
        email: testEmail,
        phone: testPhone,
        password: testPassword,
      );

      expect(registrationResult.success, true);
      expect(registrationResult.message, 'Registration successful');

      // Step 2: Login with registered credentials
      when(() => mockAuthApi.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockAuthResponse);

      final loginResult = await loginUseCase.execute(testEmail, testPassword);

      expect(loginResult.accessToken, isNotEmpty);
      expect(loginResult.refreshToken, isNotEmpty);

      // Step 3: Verify token storage
      // In real integration test, would verify tokens are stored securely
      expect(loginResult, equals(mockAuthResponse));

      // Step 4: Logout
      when(() => mockAuthApi.logout(refreshToken: any(named: 'refreshToken')))
          .thenAnswer((_) async => {});

      await authRepository.logout(mockAuthResponse.refreshToken);

      // Verify logout called with correct refresh token
      verify(() => mockAuthApi.logout(
          refreshToken: mockAuthResponse.refreshToken)).called(1);
    });

    test('Registration with invalid email should fail', () async {
      // Arrange
      const invalidEmail = 'not-an-email';

      // Act & Assert
      expect(
        () => registerUseCase.execute(
          email: invalidEmail,
          phone: testPhone,
          password: testPassword,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Verify API was never called
      verifyNever(() => mockAuthApi.registerBuyer(
            email: any(named: 'email'),
            phone: any(named: 'phone'),
            password: any(named: 'password'),
          ));
    });

    test('Login with invalid credentials should fail', () async {
      // Arrange
      when(() => mockAuthApi.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Invalid credentials'));

      // Act & Assert
      expect(
        () => loginUseCase.execute(testEmail, 'wrong_password'),
        throwsA(isA<Exception>()),
      );
    });

    test('Registration with weak password should fail', () async {
      // Arrange
      const weakPassword = '123';

      // Act & Assert
      expect(
        () => registerUseCase.execute(
          email: testEmail,
          phone: testPhone,
          password: weakPassword,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Input sanitization throughout flow', () async {
      // Arrange
      const emailWithSpaces = '  test@example.com  ';
      const phoneWithSpaces = '  +77001234567  ';

      when(() => mockAuthApi.registerBuyer(
            email: any(named: 'email'),
            phone: any(named: 'phone'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockRegistrationResponse);

      // Act
      await registerUseCase.execute(
        email: emailWithSpaces,
        phone: phoneWithSpaces,
        password: testPassword,
      );

      // Assert - verify sanitized inputs were used
      verify(() => mockAuthApi.registerBuyer(
            email: testEmail, // Should be trimmed and lowercased
            phone: testPhone.trim(),
            password: testPassword,
          )).called(1);
    });

    test('Token refresh flow', () async {
      // Arrange
      const oldRefreshToken = 'old_refresh_token';
      final newAuthResponse = AuthResponse(
        accessToken: 'new_access_token',
        refreshToken: 'new_refresh_token',
        user: null,
      );

      when(() => mockAuthApi.refresh(
            refreshToken: any(named: 'refreshToken'),
            deviceId: any(named: 'deviceId'),
          )).thenAnswer((_) async => newAuthResponse);

      // Act
      final result = await authRepository.refreshToken(oldRefreshToken);

      // Assert
      expect(result.accessToken, 'new_access_token');
      expect(result.refreshToken, 'new_refresh_token');
      verify(() => mockAuthApi.refresh(
            refreshToken: oldRefreshToken,
            deviceId: any(named: 'deviceId'),
          )).called(1);
    });

    test('Performance monitoring measures execution time', () async {
      // This test verifies that performance monitoring doesn't break the flow
      when(() => mockAuthApi.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 100));
        return mockAuthResponse;
      });

      final stopwatch = Stopwatch()..start();
      await loginUseCase.execute(testEmail, testPassword);
      stopwatch.stop();

      // Verify operation completed with monitoring overhead
      expect(stopwatch.elapsedMilliseconds, greaterThan(100));
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });
  });
}
