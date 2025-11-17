import 'package:shop_app/api/product_api.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/performance/performance_monitor.dart';
import 'package:shop_app/domain/repositories/product_repository.dart';

/// Get Products Use Case
///
/// Fetch products for a specific seller.
class GetProductsUseCase {
  GetProductsUseCase(this._productRepository);

  final IProductRepository _productRepository;

  Future<List<ProductResponse>> execute(String sellerId) async {
    return await PerformanceMonitor.measure('get_products_usecase', () async {
      if (sellerId.isEmpty) {
        AppLogger.warning('GetProductsUseCase: Empty seller ID');
        throw ArgumentError('Seller ID cannot be empty');
      }

      AppLogger.debug('GetProductsUseCase: Fetching products for seller $sellerId');

      return await _productRepository.getProductsBySeller(sellerId);
    });
  }
}
