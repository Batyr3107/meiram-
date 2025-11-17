import 'package:dio/dio.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/network/dio_client.dart';
import 'package:shop_app/services/auth_service.dart';

/// Seller API client
///
/// Handles seller-related API calls with automatic authentication.
class SellerApi {
  SellerApi() : _client = DioClient() {
    // Add auth token interceptor
    _client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
          final String? token = await AuthService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final DioClient _client;

  /// Get list of active sellers with pagination
  ///
  /// Example:
  /// ```dart
  /// final response = await sellerApi.getActiveSellers(page: 0, size: 20);
  /// ```
  Future<SellerListResponse> getActiveSellers({
    int page = 0,
    int size = 20,
  }) async {
    AppLogger.debug('Fetching sellers: page=$page, size=$size');

    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/clients/sellers',
        queryParameters: <String, dynamic>{
          'page': page,
          'size': size,
        },
      );

      AppLogger.debug('Fetched ${response.data!['content'].length} sellers');
      return SellerListResponse.fromJson(response.data!);
    } catch (e, stack) {
      AppLogger.error('Failed to fetch sellers', e, stack);
      rethrow;
    }
  }

  /// Get seller details by ID
  Future<SellerResponse> getSellerById(String sellerId) async {
    AppLogger.debug('Fetching seller: $sellerId');

    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/clients/sellers/$sellerId',
      );

      AppLogger.debug('Fetched seller: ${response.data!['organizationName']}');
      return SellerResponse.fromJson(response.data!);
    } catch (e, stack) {
      AppLogger.error('Failed to fetch seller $sellerId', e, stack);
      rethrow;
    }
  }
}

class SellerListResponse {
  final List<SellerResponse> content;
  final int totalPages;
  final int totalElements;
  final int size;
  final int number;

  SellerListResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.number,
  });

  factory SellerListResponse.fromJson(Map<String, dynamic> json) {
    return SellerListResponse(
      content: (json['content'] as List)
          .map((item) => SellerResponse.fromJson(item))
          .toList(),
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
      size: json['size'] as int,
      number: json['number'] as int,
    );
  }
}

class SellerResponse {
  final String id;
  final String organizationName;
  final String bin;
  final String description;
  final double minOrderAmount;
  final String status;

  SellerResponse({
    required this.id,
    required this.organizationName,
    required this.bin,
    required this.description,
    required this.minOrderAmount,
    required this.status,
  });

  factory SellerResponse.fromJson(Map<String, dynamic> json) {
    return SellerResponse(
      id: json['id'].toString(),
      organizationName: json['organizationName'] as String? ?? 'Неизвестный продавец',
      bin: json['bin'] as String? ?? '',
      description: json['description'] as String? ?? '',
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }
}