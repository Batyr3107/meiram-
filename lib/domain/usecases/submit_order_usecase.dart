import 'package:shop_app/api/order_api.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/performance/performance_monitor.dart';
import 'package:shop_app/core/security/input_sanitizer.dart';
import 'package:shop_app/domain/repositories/order_repository.dart';

/// Submit Order Use Case
///
/// Business logic for submitting an order from cart.
class SubmitOrderUseCase {
  SubmitOrderUseCase(this._orderRepository);

  final IOrderRepository _orderRepository;

  Future<CreateOrderResponse> execute({
    required String cartId,
    String? comment,
    String? deliveryAddress,
  }) async {
    return await PerformanceMonitor.measure('submit_order_usecase', () async {
      if (cartId.isEmpty) {
        AppLogger.warning('SubmitOrderUseCase: Empty cart ID');
        throw ArgumentError('Cart ID cannot be empty');
      }

      // Sanitize optional inputs
      final sanitizedComment = comment != null ? InputSanitizer.sanitizeText(comment) : null;
      final sanitizedAddress = deliveryAddress != null ? InputSanitizer.sanitizeText(deliveryAddress) : null;

      AppLogger.info('SubmitOrderUseCase: Submitting order for cart $cartId');

      return await _orderRepository.submitOrder(
        cartId: cartId,
        comment: sanitizedComment,
        deliveryAddress: sanitizedAddress,
      );
    });
  }
}
