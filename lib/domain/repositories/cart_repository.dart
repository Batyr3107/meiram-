import 'package:shop_app/api/cart_api.dart';

/// Cart Repository Interface
abstract class ICartRepository {
  /// Get cart for specific seller
  Future<CartResponse> getSellerCart(String sellerId);

  /// Add item to cart
  Future<CartResponse> addItemToCart({
    required String productId,
    required double quantity,
  });

  /// Remove item from cart
  Future<void> removeItemFromCart(String itemId);

  /// Update item quantity
  Future<CartResponse> updateItemQuantity({
    required String itemId,
    required double quantity,
  });

  /// Clear cart for seller
  Future<void> clearSellerCart(String sellerId);
}
