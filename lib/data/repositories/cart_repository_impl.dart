import 'package:shop_app/api/cart_api.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/performance/performance_monitor.dart';
import 'package:shop_app/domain/repositories/cart_repository.dart';

/// Cart Repository Implementation
class CartRepositoryImpl implements ICartRepository {
  CartRepositoryImpl(this._cartApi);

  final CartApi _cartApi;

  @override
  Future<CartResponse> getSellerCart(String sellerId) async {
    return await PerformanceMonitor.measure('cart_repository_get', () async {
      AppLogger.debug('CartRepository: Getting cart for seller $sellerId');

      try {
        final cart = await _cartApi.getSellerCart(sellerId);
        AppLogger.debug('CartRepository: Cart has ${cart.items.length} items');
        return cart;
      } catch (e, stack) {
        AppLogger.error('CartRepository: Failed to get cart', e, stack);
        rethrow;
      }
    });
  }

  @override
  Future<CartResponse> addItemToCart({
    required String productId,
    required double quantity,
  }) async {
    return await PerformanceMonitor.measure('cart_repository_add_item', () async {
      AppLogger.info('CartRepository: Adding product $productId x$quantity');

      try {
        final cart = await _cartApi.addItemToCart(
          productId: productId,
          quantity: quantity,
        );
        AppLogger.info('CartRepository: Item added successfully');
        return cart;
      } catch (e, stack) {
        AppLogger.error('CartRepository: Failed to add item', e, stack);
        rethrow;
      }
    });
  }

  @override
  Future<void> removeItemFromCart(String itemId) async {
    return await PerformanceMonitor.measure('cart_repository_remove_item', () async {
      AppLogger.info('CartRepository: Removing item $itemId');

      try {
        await _cartApi.removeItemFromCart(itemId);
        AppLogger.info('CartRepository: Item removed successfully');
      } catch (e, stack) {
        AppLogger.error('CartRepository: Failed to remove item', e, stack);
        rethrow;
      }
    });
  }

  @override
  Future<CartResponse> updateItemQuantity({
    required String itemId,
    required double quantity,
  }) async {
    return await PerformanceMonitor.measure('cart_repository_update_quantity', () async {
      AppLogger.info('CartRepository: Updating item $itemId quantity to $quantity');

      try {
        final cart = await _cartApi.updateItemQuantity(
          itemId: itemId,
          quantity: quantity,
        );
        AppLogger.info('CartRepository: Quantity updated successfully');
        return cart;
      } catch (e, stack) {
        AppLogger.error('CartRepository: Failed to update quantity', e, stack);
        rethrow;
      }
    });
  }

  @override
  Future<void> clearSellerCart(String sellerId) async {
    return await PerformanceMonitor.measure('cart_repository_clear', () async {
      AppLogger.info('CartRepository: Clearing cart for seller $sellerId');

      try {
        await _cartApi.clearSellerCart(sellerId);
        AppLogger.info('CartRepository: Cart cleared successfully');
      } catch (e, stack) {
        AppLogger.error('CartRepository: Failed to clear cart', e, stack);
        rethrow;
      }
    });
  }
}
