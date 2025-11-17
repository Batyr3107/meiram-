import 'package:shop_app/api/seller_api.dart';

/// Seller Repository Interface
abstract class ISellerRepository {
  /// Get list of active sellers with pagination
  Future<SellerListResponse> getActiveSellers({
    int page = 0,
    int size = 20,
  });

  /// Get seller details by ID
  Future<SellerResponse> getSellerById(String sellerId);
}
