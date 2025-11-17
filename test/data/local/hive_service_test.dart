import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shop_app/data/local/hive_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HiveService', () {
    setUp(() async {
      // Initialize Hive with a temporary path for testing
      await Hive.initFlutter();
    });

    tearDown(() async {
      // Close all boxes and delete from disk
      await Hive.close();
      await Hive.deleteFromDisk();
    });

    group('Cache Timestamp Management', () {
      test('should return false for non-existent cache', () async {
        // Arrange
        await Hive.openBox(HiveService.cacheBox);

        // Act
        final isFresh = HiveService.isCacheFresh('test_key');

        // Assert
        expect(isFresh, false);
      });

      test('should return true for fresh cache', () async {
        // Arrange
        await Hive.openBox(HiveService.cacheBox);
        await HiveService.updateCacheTimestamp('test_key');

        // Act
        final isFresh = HiveService.isCacheFresh('test_key');

        // Assert
        expect(isFresh, true);
      });

      test('should return false for stale cache', () async {
        // Arrange
        await Hive.openBox(HiveService.cacheBox);

        // Set timestamp to 10 minutes ago
        final oldTimestamp =
            DateTime.now().subtract(const Duration(minutes: 10));
        await HiveService.cache.put(
          'test_key_timestamp',
          oldTimestamp.millisecondsSinceEpoch,
        );

        // Act
        final isFresh = HiveService.isCacheFresh(
          'test_key',
          ttl: const Duration(minutes: 5),
        );

        // Assert
        expect(isFresh, false);
      });

      test('should respect custom TTL', () async {
        // Arrange
        await Hive.openBox(HiveService.cacheBox);
        await HiveService.updateCacheTimestamp('test_key');

        // Act - check with very short TTL
        await Future.delayed(const Duration(milliseconds: 100));
        final isFresh = HiveService.isCacheFresh(
          'test_key',
          ttl: const Duration(milliseconds: 50),
        );

        // Assert
        expect(isFresh, false);
      });

      test('should update cache timestamp correctly', () async {
        // Arrange
        await Hive.openBox(HiveService.cacheBox);

        // Set old timestamp
        final oldTimestamp =
            DateTime.now().subtract(const Duration(minutes: 10));
        await HiveService.cache.put(
          'test_key_timestamp',
          oldTimestamp.millisecondsSinceEpoch,
        );

        // Act
        await HiveService.updateCacheTimestamp('test_key');

        // Assert
        final isFresh = HiveService.isCacheFresh('test_key');
        expect(isFresh, true);
      });
    });

    group('Box Management', () {
      test('should open all required boxes during init', () async {
        // Act
        await HiveService.init();

        // Assert
        expect(Hive.isBoxOpen(HiveService.productsBox), true);
        expect(Hive.isBoxOpen(HiveService.sellersBox), true);
        expect(Hive.isBoxOpen(HiveService.ordersBox), true);
        expect(Hive.isBoxOpen(HiveService.cacheBox), true);
      });

      test('should provide access to products box', () async {
        // Arrange
        await HiveService.init();

        // Act
        final box = HiveService.products;

        // Assert
        expect(box, isNotNull);
        expect(box.name, HiveService.productsBox);
      });

      test('should provide access to sellers box', () async {
        // Arrange
        await HiveService.init();

        // Act
        final box = HiveService.sellers;

        // Assert
        expect(box, isNotNull);
        expect(box.name, HiveService.sellersBox);
      });

      test('should provide access to orders box', () async {
        // Arrange
        await HiveService.init();

        // Act
        final box = HiveService.orders;

        // Assert
        expect(box, isNotNull);
        expect(box.name, HiveService.ordersBox);
      });

      test('should provide access to cache box', () async {
        // Arrange
        await HiveService.init();

        // Act
        final box = HiveService.cache;

        // Assert
        expect(box, isNotNull);
        expect(box.name, HiveService.cacheBox);
      });
    });

    group('Clear Operations', () {
      test('should clear all boxes', () async {
        // Arrange
        await HiveService.init();

        // Add test data
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

      test('should handle clear errors gracefully', () async {
        // Arrange
        await HiveService.init();

        // Act & Assert - should not throw
        await HiveService.clearAll();
        expect(HiveService.products.isEmpty, true);
      });
    });

    group('Data Persistence', () {
      test('should persist data across box access', () async {
        // Arrange
        await HiveService.init();
        const testData = {'id': '1', 'name': 'Test Product'};

        // Act
        await HiveService.products.put('product1', testData);
        final retrieved = HiveService.products.get('product1');

        // Assert
        expect(retrieved, equals(testData));
      });

      test('should handle multiple cache keys independently', () async {
        // Arrange
        await HiveService.init();

        // Act
        await HiveService.updateCacheTimestamp('key1');
        await Future.delayed(const Duration(milliseconds: 100));
        await HiveService.updateCacheTimestamp('key2');

        // Assert
        final key1Fresh = HiveService.isCacheFresh('key1');
        final key2Fresh = HiveService.isCacheFresh('key2');
        expect(key1Fresh, true);
        expect(key2Fresh, true);
      });
    });
  });
}
