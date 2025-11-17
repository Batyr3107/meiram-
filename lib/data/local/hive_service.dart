import 'package:hive_flutter/hive_flutter.dart';
import 'package:shop_app/core/logger/app_logger.dart';

/// Hive Local Storage Service
///
/// Manages offline data storage using Hive database.
class HiveService {
  // Box names
  static const String productsBox = 'products';
  static const String sellersBox = 'sellers';
  static const String ordersBox = 'orders';
  static const String cacheBox = 'cache';

  /// Initialize Hive
  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      AppLogger.info('Hive initialized successfully');

      // Open boxes
      await Hive.openBox<Map>(productsBox);
      await Hive.openBox<Map>(sellersBox);
      await Hive.openBox<Map>(ordersBox);
      await Hive.openBox(cacheBox);

      AppLogger.info('Hive boxes opened successfully');
    } catch (e, stack) {
      AppLogger.error('Failed to initialize Hive', e, stack);
      rethrow;
    }
  }

  /// Get products box
  static Box<Map> get products => Hive.box<Map>(productsBox);

  /// Get sellers box
  static Box<Map> get sellers => Hive.box<Map>(sellersBox);

  /// Get orders box
  static Box<Map> get orders => Hive.box<Map>(ordersBox);

  /// Get cache box
  static Box get cache => Hive.box(cacheBox);

  /// Clear all offline data
  static Future<void> clearAll() async {
    try {
      await products.clear();
      await sellers.clear();
      await orders.clear();
      await cache.clear();
      AppLogger.info('All offline data cleared');
    } catch (e, stack) {
      AppLogger.error('Failed to clear offline data', e, stack);
    }
  }

  /// Check if cache is fresh
  static bool isCacheFresh(String key, {Duration ttl = const Duration(minutes: 5)}) {
    final timestamp = cache.get('${key}_timestamp');
    if (timestamp == null) return false;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
    return DateTime.now().difference(cacheTime) < ttl;
  }

  /// Update cache timestamp
  static Future<void> updateCacheTimestamp(String key) async {
    await cache.put('${key}_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  /// Close all boxes
  static Future<void> close() async {
    await Hive.close();
    AppLogger.info('Hive closed');
  }
}
