import 'package:dio/dio.dart';
import '../dto/auth_response.dart';
import '../dto/registration_response.dart';

class AuthApi {
  final Dio dio;

  AuthApi(String baseUrl)
      : dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  // Регистрация покупателя
  Future<RegistrationResponse> registerBuyer({
    required String email,
    required String phone,
    required String password,
  }) async {
    final body = {
      'role': 'BUYER',
      'email': email,
      'phone': phone,
      'password': password,
    };
    print('Register request: $body');
    final res = await dio.post('/auth/register', data: body);
    return RegistrationResponse.fromJson(res.data);
  }

  // Вход в аккаунт
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final body = {
        'username': email,
        'password': password,
        'deviceId': 'flutter-web-${DateTime.now().millisecondsSinceEpoch}',
      };

      print('Login request body: $body');

      final res = await dio.post('/auth/login', data: body);

      print('Login response status: ${res.statusCode}');
      print('Login response data: ${res.data}');

      return AuthResponse.fromJson(res.data); // ← ИСПОЛЬЗУЕТСЯ ИЗ DTO!
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Обновление токена
  Future<AuthResponse> refresh({
    required String refreshToken,
    required String deviceId,
  }) async {
    final body = {
      'refreshToken': refreshToken,
      'deviceId': deviceId,
    };
    print('Refresh request body: $body');
    final res = await dio.post('/auth/refresh', data: body);
    print('Refresh response: ${res.data}');
    return AuthResponse.fromJson(res.data);
  }

  // Выход
  Future<void> logout({required String refreshToken}) async {
    final body = {'refreshToken': refreshToken};
    await dio.post('/auth/logout', data: body);
  }
}