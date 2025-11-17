import '../api/product_api.dart';

class ProductCache {
  static final Map<String, List<ProductResponse>> _cache = {};
  static final Map<String, DateTime> _timestamps = {};

  static const Duration cacheDuration = Duration(minutes: 5);

  // Ключ: userId|sellerId
  static String _key(String userId, String sellerId) => '$userId|$sellerId';

  static List<ProductResponse>? get(String userId, String sellerId) {
    final key = _key(userId, sellerId);
    final data = _cache[key];
    final timestamp = _timestamps[key];

    if (data != null && timestamp != null) {
      if (DateTime.now().difference(timestamp) < cacheDuration) {
        return data;
      } else {
        _cache.remove(key);
        _timestamps.remove(key);
      }
    }
    return null;
  }

  static void set(String userId, String sellerId, List<ProductResponse> products) {
    final key = _key(userId, sellerId);
    _cache[key] = products;
    _timestamps[key] = DateTime.now();
  }

  static void clear() {
    _cache.clear();
    _timestamps.clear();
  }
}