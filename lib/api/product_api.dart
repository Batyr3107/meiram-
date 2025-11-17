import 'package:dio/dio.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/network/dio_client.dart';
import 'package:shop_app/services/auth_service.dart';

/// Product data model
class ProductResponse {
  ProductResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
    required this.price,
    required this.minOrderQty,
    required this.active,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> j) {
    return ProductResponse(
      id: j['id'].toString(),
      name: (j['name'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      unit: (j['unit'] ?? '').toString(),
      price: (j['price'] as num?)?.toDouble() ?? 0,
      minOrderQty: (j['minOrderQty'] as num?)?.toDouble() ?? 0,
      active: j['active'] as bool? ?? true,
    );
  }

  final String id;
  final String name;
  final String description;
  final String unit;
  final double price;
  final double minOrderQty;
  final bool active;
}

/// Product API client
///
/// Handles product-related API calls with automatic authentication.
class ProductApi {
  ProductApi() : _client = DioClient() {
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

  /// Get products by seller ID
  ///
  /// Example:
  /// ```dart
  /// final products = await productApi.getBySeller('seller_123');
  /// ```
  Future<List<ProductResponse>> getBySeller(String sellerId) async {
    AppLogger.debug('Fetching products for seller: $sellerId');

    try {
      final response = await _client.get<List<dynamic>>(
        '/products/by-seller/$sellerId',
      );

      final List<ProductResponse> products = (response.data as List<dynamic>)
          .map((dynamic e) => ProductResponse.fromJson(e as Map<String, dynamic>))
          .toList();

      AppLogger.debug('Fetched ${products.length} products for seller $sellerId');
      return products;
    } catch (e, stack) {
      AppLogger.error('Failed to fetch products for seller $sellerId', e, stack);
      rethrow;
    }
  }
}
