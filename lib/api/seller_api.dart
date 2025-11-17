import 'package:dio/dio.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/network/auth_interceptor.dart';
import 'package:shop_app/core/network/dio_client.dart';

/// Seller API client
///
/// Handles seller-related API calls with automatic authentication.
class SellerApi {
  SellerApi() : _client = DioClient() {
    // Add auth interceptor (without User-Id header)
    _client.dio.interceptors.add(SimpleAuthInterceptor());
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

      if (response.data == null) {
        throw Exception('Empty response from server');
      }

      final contentLength = (response.data!['content'] as List?)?.length ?? 0;
      AppLogger.debug('Fetched $contentLength sellers');
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

      if (response.data == null) {
        throw Exception('Empty response from server');
      }

      final orgName = response.data!['organizationName'] ?? 'Unknown';
      AppLogger.debug('Fetched seller: $orgName');
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
      content: (json['content'] as List?)
              ?.map((item) => SellerResponse.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      size: json['size'] as int? ?? 0,
      number: json['number'] as int? ?? 0,
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
    // Validate required field
    if (json['id'] == null) {
      throw FormatException('Missing required field: id');
    }

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