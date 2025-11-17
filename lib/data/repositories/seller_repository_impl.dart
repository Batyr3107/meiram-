import 'package:shop_app/api/seller_api.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/performance/performance_monitor.dart';
import 'package:shop_app/domain/repositories/seller_repository.dart';

/// Seller Repository Implementation
class SellerRepositoryImpl implements ISellerRepository {
  SellerRepositoryImpl(this._sellerApi);

  final SellerApi _sellerApi;

  @override
  Future<SellerListResponse> getActiveSellers({
    int page = 0,
    int size = 20,
  }) async {
    return await PerformanceMonitor.measure('seller_repository_get_active', () async {
      AppLogger.debug('SellerRepository: Fetching sellers page=$page, size=$size');

      try {
        final sellersPage = await _sellerApi.getActiveSellers(
          page: page,
          size: size,
        );
        AppLogger.debug('SellerRepository: Found ${sellersPage.content.length} sellers');
        return sellersPage;
      } catch (e, stack) {
        AppLogger.error('SellerRepository: Failed to fetch sellers', e, stack);
        rethrow;
      }
    });
  }

  @override
  Future<SellerResponse> getSellerById(String sellerId) async {
    return await PerformanceMonitor.measure('seller_repository_get_by_id', () async {
      AppLogger.debug('SellerRepository: Fetching seller $sellerId');

      try {
        final seller = await _sellerApi.getSellerById(sellerId);
        AppLogger.debug('SellerRepository: Seller ${seller.organizationName} loaded');
        return seller;
      } catch (e, stack) {
        AppLogger.error('SellerRepository: Failed to fetch seller', e, stack);
        rethrow;
      }
    });
  }
}
