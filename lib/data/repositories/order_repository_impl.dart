import 'package:shop_app/api/order_api.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/performance/performance_monitor.dart';
import 'package:shop_app/domain/repositories/order_repository.dart';

/// Order Repository Implementation
class OrderRepositoryImpl implements IOrderRepository {
  OrderRepositoryImpl(this._orderApi);

  final OrderApi _orderApi;

  @override
  Future<CreateOrderResponse> submitOrder({
    required String cartId,
    String? comment,
    String? deliveryAddress,
  }) async {
    return await PerformanceMonitor.measure('order_repository_submit', () async {
      AppLogger.info('OrderRepository: Submitting order for cart $cartId');

      try {
        final order = await _orderApi.submitOrder(
          cartId: cartId,
          comment: comment,
          deliveryAddress: deliveryAddress,
        );
        AppLogger.info('OrderRepository: Order ${order.orderId} created successfully');
        return order;
      } catch (e, stack) {
        AppLogger.error('OrderRepository: Failed to submit order', e, stack);
        rethrow;
      }
    });
  }

  @override
  Future<OrdersPageResponse> getBuyerOrders({
    int page = 0,
    int size = 20,
  }) async {
    return await PerformanceMonitor.measure('order_repository_get_orders', () async {
      AppLogger.debug('OrderRepository: Fetching orders page=$page, size=$size');

      try {
        final ordersPage = await _orderApi.getBuyerOrders(
          page: page,
          size: size,
        );
        AppLogger.debug('OrderRepository: Found ${ordersPage.content.length} orders');
        return ordersPage;
      } catch (e, stack) {
        AppLogger.error('OrderRepository: Failed to fetch orders', e, stack);
        rethrow;
      }
    });
  }

  @override
  Future<BuyerOrderDetailResponse> getOrderDetails(String orderId) async {
    return await PerformanceMonitor.measure('order_repository_get_details', () async {
      AppLogger.debug('OrderRepository: Fetching details for order $orderId');

      try {
        final orderDetails = await _orderApi.getOrderDetails(orderId);
        AppLogger.debug('OrderRepository: Order details loaded successfully');
        return orderDetails;
      } catch (e, stack) {
        AppLogger.error('OrderRepository: Failed to fetch order details', e, stack);
        rethrow;
      }
    });
  }
}
