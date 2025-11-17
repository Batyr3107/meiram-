import 'package:dio/dio.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/network/auth_interceptor.dart';
import 'package:shop_app/core/network/dio_client.dart';

/// Cart API client
///
/// Handles shopping cart operations with automatic authentication.
class CartApi {
  CartApi() : _client = DioClient() {
    // Add auth interceptor
    _client.dio.interceptors.add(AuthInterceptor());
  }

  final DioClient _client;

  /// Get cart for specific seller
  Future<CartResponse> getSellerCart(String sellerId) async {
    AppLogger.debug('Getting cart for seller: $sellerId');

    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/orders/cart/seller/$sellerId',
      );

      if (response.data == null) {
        AppLogger.debug('Cart not found, returning empty cart');
        return CartResponse.empty(sellerId: sellerId);
      }

      AppLogger.debug('Cart retrieved for seller: $sellerId');
      return CartResponse.fromJson(response.data!);
    } on DioException catch (e, stack) {
      AppLogger.warning('Cart error: ${e.response?.statusCode}');

      if (e.response?.statusCode == 404) {
        AppLogger.debug('Cart not found for seller, returning empty cart');
        return CartResponse.empty(sellerId: sellerId);
      }

      AppLogger.error('Failed to get cart for seller $sellerId', e, stack);
      rethrow;
    }
  }

  /// Add item to cart (backend determines seller from productId)
  Future<CartResponse> addItemToCart({
    required String productId,
    required double quantity,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'productId': productId,
      'quantity': quantity,
    };

    AppLogger.info('Adding to cart: $productId x $quantity');

    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/orders/cart/items',
        data: body,
      );

      if (response.data == null) {
        throw Exception('Empty response from server');
      }

      AppLogger.info('Item added to cart successfully');
      return CartResponse.fromJson(response.data!);
    } catch (e, stack) {
      AppLogger.error('Failed to add item to cart', e, stack);
      rethrow;
    }
  }

  /// Remove item from cart
  Future<void> removeItemFromCart(String itemId) async {
    AppLogger.info('Removing item from cart: $itemId');

    try {
      await _client.delete<void>('/orders/cart/items/$itemId');
      AppLogger.info('Item removed successfully');
    } catch (e, stack) {
      AppLogger.error('Failed to remove item $itemId', e, stack);
      rethrow;
    }
  }

  /// Update item quantity
  Future<CartResponse> updateItemQuantity({
    required String itemId,
    required double quantity,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{'quantity': quantity};

    AppLogger.info('Updating item $itemId quantity to $quantity');

    try {
      final response = await _client.put<Map<String, dynamic>>(
        '/orders/cart/items/$itemId',
        data: body,
      );

      if (response.data == null) {
        throw Exception('Empty response from server');
      }

      AppLogger.info('Item quantity updated successfully');
      return CartResponse.fromJson(response.data!);
    } catch (e, stack) {
      AppLogger.error('Failed to update item quantity', e, stack);
      rethrow;
    }
  }

  /// Clear cart for specific seller
  Future<void> clearSellerCart(String sellerId) async {
    AppLogger.info('Clearing cart for seller: $sellerId');

    try {
      await _client.delete<void>('/orders/cart/seller/$sellerId');
      AppLogger.info('Seller cart cleared successfully');
    } catch (e, stack) {
      AppLogger.error('Failed to clear cart for seller $sellerId', e, stack);
      rethrow;
    }
  }
}

// ============================================
// ОБНОВЛЕННЫЕ МОДЕЛИ ДАННЫХ
// ============================================
class CartResponse {
  final String cartId;
  final String sellerId;
  final List<CartItemResponse> items;
  final double totalAmount;

  CartResponse({
    required this.cartId,
    required this.sellerId,
    required this.items,
    required this.totalAmount,
  });

  // Конструктор для пустой корзины
  static CartResponse empty({required String sellerId}) {
    return CartResponse(
      cartId: '',
      sellerId: sellerId,
      items: [],
      totalAmount: 0.0,
    );
  }

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    final String cartId = json['cartId']?.toString() ?? '';
    AppLogger.debug('Parsing cart response - cartId: $cartId');

    return CartResponse(
      cartId: cartId,
      sellerId: json['sellerId']?.toString() ?? '',
      items: (json['items'] as List?)
          ?.map((e) => CartItemResponse.fromJson(e))
          .toList() ?? [],
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Геттер для количества товаров
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity.toInt());

  Map<String, SellerCartInfo> get sellerInfo => {};
}

class CartItemResponse {
  final String itemId;
  final String productId;
  final String productName;
  final String unit;
  final double price;
  final double quantity;
  final double subtotal;
  final String sellerId;
  final String sellerName;

  CartItemResponse({
    required this.itemId,
    required this.productId,
    required this.productName,
    required this.unit,
    required this.price,
    required this.quantity,
    required this.subtotal,
    required this.sellerId,
    required this.sellerName,
  });

  factory CartItemResponse.fromJson(Map<String, dynamic> json) {
    return CartItemResponse(
      itemId: json['itemId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? 'Товар',
      unit: json['unit']?.toString() ?? 'шт',
      price: json['price'] != null
          ? (json['price'] as num).toDouble()
          : (json['amount'] != null && json['quantity'] != null && json['quantity'] > 0)
          ? (json['amount'] as num).toDouble() / (json['quantity'] as num).toDouble()
          : 0.0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['amount'] as num?)?.toDouble() ?? 0.0,
      sellerId: json['sellerId']?.toString() ?? '',
      sellerName: json['sellerName']?.toString() ?? 'Продавец',
    );
  }
}

class SellerCartInfo {
  final String sellerId;
  final String sellerName;
  final double subtotal;
  final double minOrderAmount;
  final bool meetsMinimum;

  SellerCartInfo({
    required this.sellerId,
    required this.sellerName,
    required this.subtotal,
    required this.minOrderAmount,
    required this.meetsMinimum,
  });

  factory SellerCartInfo.fromJson(Map<String, dynamic> json) {
    return SellerCartInfo(
      sellerId: json['sellerId']?.toString() ?? '',
      sellerName: json['sellerName']?.toString() ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
      meetsMinimum: json['meetsMinimum'] as bool? ?? true,
    );
  }
}