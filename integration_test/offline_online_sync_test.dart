import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shop_app/data/local/hive_service.dart';

/// Integration test for offline/online synchronization
///
/// Tests:
/// 1. Offline data caching
/// 2. Cache TTL validation
/// 3. Online sync after offline mode
/// 4. Cache invalidation
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Initialize Hive for testing
    await Hive.initFlutter();
  });

  tearDown(() async {
    // Clean up after each test
    await Hive.close();
    await Hive.deleteFromDisk();
  });

  group('Offline/Online Sync Integration Tests', () {
    test('HiveService initializes all boxes', () async {
      // Act
      await HiveService.init();

      // Assert
      expect(Hive.isBoxOpen(HiveService.productsBox), true);
      expect(Hive.isBoxOpen(HiveService.sellersBox), true);
      expect(Hive.isBoxOpen(HiveService.ordersBox), true);
      expect(Hive.isBoxOpen(HiveService.cacheBox), true);
    });

    test('Cache timestamp management', () async {
      // Arrange
      await HiveService.init();
      const cacheKey = 'test_products';

      // Act - Update timestamp
      await HiveService.updateCacheTimestamp(cacheKey);

      // Assert - Cache should be fresh
      final isFresh = HiveService.isCacheFresh(cacheKey);
      expect(isFresh, true);

      // Wait and check again with short TTL
      await Future.delayed(const Duration(milliseconds: 200));
      final isStillFresh = HiveService.isCacheFresh(
        cacheKey,
        ttl: const Duration(milliseconds: 100),
      );
      expect(isStillFresh, false);
    });

    test('Offline data persistence and retrieval', () async {
      // Arrange
      await HiveService.init();

      final testData = {
        'id': 'product123',
        'name': 'Test Product',
        'price': 99.99,
      };

      // Act - Store offline
      await HiveService.products.put('product123', testData);

      // Simulate app restart
      await Hive.close();
      await HiveService.init();

      // Assert - Data should persist
      final retrieved = HiveService.products.get('product123');
      expect(retrieved, isNotNull);
      expect(retrieved!['id'], equals('product123'));
      expect(retrieved['name'], equals('Test Product'));
      expect(retrieved['price'], equals(99.99));
    });

    test('Cache invalidation clears stale data', () async {
      // Arrange
      await HiveService.init();

      await HiveService.products.put('product1', {'name': 'Product 1'});
      await HiveService.sellers.put('seller1', {'name': 'Seller 1'});
      await HiveService.orders.put('order1', {'total': 100.0});
      await HiveService.cache.put('cache1', 'value1');

      // Act
      await HiveService.clearAll();

      // Assert
      expect(HiveService.products.isEmpty, true);
      expect(HiveService.sellers.isEmpty, true);
      expect(HiveService.orders.isEmpty, true);
      expect(HiveService.cache.isEmpty, true);
    });

    test('Multiple cache keys work independently', () async {
      // Arrange
      await HiveService.init();

      // Act - Create timestamps at different times
      await HiveService.updateCacheTimestamp('products');
      await Future.delayed(const Duration(milliseconds: 100));
      await HiveService.updateCacheTimestamp('sellers');
      await Future.delayed(const Duration(milliseconds: 100));
      await HiveService.updateCacheTimestamp('orders');

      // Assert - All should be fresh with default TTL
      expect(HiveService.isCacheFresh('products'), true);
      expect(HiveService.isCacheFresh('sellers'), true);
      expect(HiveService.isCacheFresh('orders'), true);

      // Products cache is oldest, should expire first
      await Future.delayed(const Duration(milliseconds: 50));
      expect(
        HiveService.isCacheFresh('products',
            ttl: const Duration(milliseconds: 200)),
        false,
      );
      expect(
        HiveService.isCacheFresh('sellers',
            ttl: const Duration(milliseconds: 200)),
        true,
      );
    });

    test('Offline → Online sync simulation', () async {
      // Arrange
      await HiveService.init();

      // Simulate offline mode - save data locally
      final offlineProducts = [
        {'id': '1', 'name': 'Product 1', 'synced': false},
        {'id': '2', 'name': 'Product 2', 'synced': false},
      ];

      for (final product in offlineProducts) {
        await HiveService.products.put(product['id'], product);
      }

      // Act - Simulate coming online
      final unsyncedProducts = <String, dynamic>{};
      for (final key in HiveService.products.keys) {
        final product = HiveService.products.get(key);
        if (product != null && product['synced'] == false) {
          unsyncedProducts[key] = product;
        }
      }

      // Assert
      expect(unsyncedProducts.length, equals(2));

      // Mark as synced
      for (final key in unsyncedProducts.keys) {
        final product = unsyncedProducts[key];
        product['synced'] = true;
        await HiveService.products.put(key, product);
      }

      // Verify all synced
      final product1 = HiveService.products.get('1');
      expect(product1!['synced'], true);
    });

    test('Cache TTL with different durations', () async {
      // Arrange
      await HiveService.init();
      await HiveService.updateCacheTimestamp('short_ttl');
      await HiveService.updateCacheTimestamp('long_ttl');

      // Act & Assert - Check with different TTLs
      await Future.delayed(const Duration(milliseconds: 150));

      // Short TTL should be stale
      expect(
        HiveService.isCacheFresh('short_ttl',
            ttl: const Duration(milliseconds: 100)),
        false,
      );

      // Long TTL should be fresh
      expect(
        HiveService.isCacheFresh('long_ttl',
            ttl: const Duration(seconds: 5)),
        true,
      );
    });

    test('Large dataset caching performance', () async {
      // Arrange
      await HiveService.init();
      final stopwatch = Stopwatch()..start();

      // Act - Store 1000 products
      for (int i = 0; i < 1000; i++) {
        await HiveService.products.put('product_$i', {
          'id': 'product_$i',
          'name': 'Product $i',
          'price': i * 10.0,
        });
      }

      stopwatch.stop();

      // Assert - Should complete in reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      expect(HiveService.products.length, equals(1000));

      // Retrieval should be fast
      stopwatch.reset();
      stopwatch.start();

      final product500 = HiveService.products.get('product_500');
      stopwatch.stop();

      expect(product500, isNotNull);
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    test('Cache miss returns null', () async {
      // Arrange
      await HiveService.init();

      // Act & Assert
      expect(HiveService.isCacheFresh('non_existent_key'), false);
      expect(HiveService.products.get('non_existent_product'), null);
    });

    test('Box operations are isolated', () async {
      // Arrange
      await HiveService.init();

      // Act - Add data to different boxes
      await HiveService.products.put('key1', {'type': 'product'});
      await HiveService.sellers.put('key1', {'type': 'seller'});
      await HiveService.orders.put('key1', {'type': 'order'});

      // Assert - Same key in different boxes is independent
      final productData = HiveService.products.get('key1');
      final sellerData = HiveService.sellers.get('key1');
      final orderData = HiveService.orders.get('key1');

      expect(productData!['type'], equals('product'));
      expect(sellerData!['type'], equals('seller'));
      expect(orderData!['type'], equals('order'));
    });
  });
}
