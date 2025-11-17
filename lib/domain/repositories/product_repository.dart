import 'package:shop_app/api/product_api.dart';

/// Product Repository Interface
abstract class IProductRepository {
  /// Get all products for a specific seller
  Future<List<ProductResponse>> getProductsBySeller(String sellerId);
}
