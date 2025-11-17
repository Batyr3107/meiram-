import 'dart:async';
import 'package:shop_app/core/logger/app_logger.dart';
import '../api/cart_api.dart';

class CartService {
  static final Map<String, CartResponse> _sellerCarts = {};
  static final Map<String, StreamController<CartResponse>> _cartStreams = {};

  // Получить корзину для продавца (из кэша или с бэкенда)
  static Future<CartResponse> getSellerCart(String sellerId) async {
    // Если уже в кэше - возвращаем
    if (_sellerCarts.containsKey(sellerId)) {
      return _sellerCarts[sellerId]!;
    }

    // Загружаем с бэкенда
    try {
      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: '');
      final cartApi = CartApi(baseUrl);
      final cart = await cartApi.getSellerCart(sellerId);

      _sellerCarts[sellerId] = cart;
      _notifyCartUpdate(sellerId, cart);
      return cart;
    } catch (e) {
      AppLogger.error('Failed to load cart for seller $sellerId', e);
      final emptyCart = CartResponse.empty(sellerId: sellerId);
      _sellerCarts[sellerId] = emptyCart;
      return emptyCart;
    }
  }

  // Добавить товар в корзину продавца
  static Future<CartResponse> addToSellerCart({
    required String sellerId,
    required String productId,
    required double quantity,
  }) async {
    try {
      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: '');
      final cartApi = CartApi(baseUrl);
      final updatedCart = await cartApi.addItemToCart(
        productId: productId,
        quantity: quantity,
      );

      // Обновляем кэш
      _sellerCarts[sellerId] = updatedCart;
      _notifyCartUpdate(sellerId, updatedCart);
      return updatedCart;
    } catch (e) {
      AppLogger.error('Failed to add item to cart', e);
      rethrow;
    }
  }

  // Удалить товар из корзины
  static Future<void> removeItemFromCart(String sellerId, String itemId) async {
    try {
      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: '');
      final cartApi = CartApi(baseUrl);
      await cartApi.removeItemFromCart(itemId);

      // Перезагружаем корзину для обновления кэша
      final updatedCart = await cartApi.getSellerCart(sellerId);
      _sellerCarts[sellerId] = updatedCart;
      _notifyCartUpdate(sellerId, updatedCart);
    } catch (e) {
      AppLogger.error('Failed to remove item from cart', e);
      rethrow;
    }
  }

  // Обновить количество товара
  static Future<CartResponse> updateItemQuantity({
    required String sellerId,
    required String itemId,
    required double quantity,
  }) async {
    try {
      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: '');
      final cartApi = CartApi(baseUrl);
      final updatedCart = await cartApi.updateItemQuantity(
        itemId: itemId,
        quantity: quantity,
      );

      _sellerCarts[sellerId] = updatedCart;
      _notifyCartUpdate(sellerId, updatedCart);
      return updatedCart;
    } catch (e) {
      AppLogger.error('Failed to update item quantity', e);
      rethrow;
    }
  }

  // Очистить корзину продавца
  static Future<void> clearSellerCart(String sellerId) async {
    try {
      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: '');
      final cartApi = CartApi(baseUrl);
      await cartApi.clearSellerCart(sellerId);

      final emptyCart = CartResponse.empty(sellerId: sellerId);
      _sellerCarts[sellerId] = emptyCart;
      _notifyCartUpdate(sellerId, emptyCart);
    } catch (e) {
      AppLogger.error('Failed to clear cart', e);
      rethrow;
    }
  }

  // Стрим для отслеживания изменений корзины
  static Stream<CartResponse> watchSellerCart(String sellerId) {
    _cartStreams[sellerId] ??= StreamController<CartResponse>.broadcast();
    return _cartStreams[sellerId]!.stream;
  }

  // Получить количество товаров в корзине продавца
  static int getCartItemCount(String sellerId) {
    final cart = _sellerCarts[sellerId];
    if (cart == null) return 0;
    return cart.itemCount;
  }

  // Получить текущую корзину из кэша
  static CartResponse? getCachedCart(String sellerId) {
    return _sellerCarts[sellerId];
  }

  // Очистить кэш корзины (при logout)
  static void clearCache() {
    _sellerCarts.clear();
    for (final controller in _cartStreams.values) {
      controller.close();
    }
    _cartStreams.clear();
  }

  // Уведомить об изменении корзины
  static void _notifyCartUpdate(String sellerId, CartResponse cart) {
    if (_cartStreams.containsKey(sellerId)) {
      _cartStreams[sellerId]!.add(cart);
    }
  }
}