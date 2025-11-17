import 'package:shop_app/api/order_api.dart';

/// Order Repository Interface
abstract class IOrderRepository {
  /// Submit order from cart
  Future<CreateOrderResponse> submitOrder({
    required String cartId,
    String? comment,
    String? deliveryAddress,
  });

  /// Get buyer's orders with pagination
  Future<OrdersPageResponse> getBuyerOrders({
    int page = 0,
    int size = 20,
  });

  /// Get order details by ID
  Future<BuyerOrderDetailResponse> getOrderDetails(String orderId);
}
