import 'package:dio/dio.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/network/auth_interceptor.dart';
import 'package:shop_app/core/network/dio_client.dart';

/// User API client
///
/// Handles user profile operations with automatic authentication.
class UserApi {
  UserApi() : _client = DioClient() {
    // Add auth interceptor
    _client.dio.interceptors.add(AuthInterceptor());
  }

  final DioClient _client;

  /// Get current user profile
  Future<UserProfileResponse> getMe() async {
    AppLogger.debug('Fetching user profile');

    try {
      final response = await _client.get<Map<String, dynamic>>('/users/me');

      if (response.data == null) {
        throw Exception('Empty response from server');
      }

      AppLogger.debug('User profile retrieved');
      return UserProfileResponse.fromJson(response.data!);
    } catch (e, stack) {
      AppLogger.error('Failed to fetch user profile', e, stack);
      rethrow;
    }
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
    // Validate required fields
    if (json['id'] == null) {
      throw FormatException('Missing required field: id');
    }
    if (json['username'] == null) {
      throw FormatException('Missing required field: username');
    }

    return UserProfileResponse(
      id: json['id'].toString(),
      email: json['username'].toString(), // ← важно!
      phone: json['phone']?.toString(),
    );
  }
}