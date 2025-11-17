import 'package:shop_app/api/product_api.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/performance/performance_monitor.dart';
import 'package:shop_app/domain/repositories/product_repository.dart';

/// Product Repository Implementation
class ProductRepositoryImpl implements IProductRepository {
  ProductRepositoryImpl(this._productApi);

  final ProductApi _productApi;

  @override
  Future<List<ProductResponse>> getProductsBySeller(String sellerId) async {
    return await PerformanceMonitor.measure('product_repository_get_by_seller', () async {
      AppLogger.debug('ProductRepository: Fetching products for seller $sellerId');

      try {
        final products = await _productApi.getBySeller(sellerId);
        AppLogger.debug('ProductRepository: Found ${products.length} products');
        return products;
      } catch (e, stack) {
        AppLogger.error('ProductRepository: Failed to fetch products', e, stack);
        rethrow;
      }
    });
  }
}
