import 'package:dio/dio.dart';
import '../services/auth_service.dart';

class UserApi {
  final Dio _dio;

  UserApi(String baseUrl)
      : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        await AuthService.ensureLoaded();
        final token = AuthService.accessToken;
        final userId = AuthService.userId;

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (userId != null) {
          options.headers['X-User-Id'] = userId;
        }
        handler.next(options);
      },
    ));
  }

  Future<UserProfileResponse> getMe() async {
    final response = await _dio.get('/users/me');
    return UserProfileResponse.fromJson(response.data);
  }
}

class UserProfileResponse {
  final String id;
  final String email;  // в бэкенде: username = email
  final String? phone;

  UserProfileResponse({
    required this.id,
    required this.email,
    this.phone,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      id: json['id'].toString(),
      email: json['username'].toString(), // ← важно!
      phone: json['phone']?.toString(),
    );
  }
}