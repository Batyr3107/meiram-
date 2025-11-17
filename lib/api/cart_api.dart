import 'package:dio/dio.dart';
import '../services/auth_service.dart';

class CartApi {
  final Dio dio;

  CartApi(String baseUrl) : dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        await AuthService.ensureLoaded();

        final token = AuthService.accessToken;
        final userId = AuthService.userId;

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        if (userId != null && userId.isNotEmpty) {
          options.headers['X-User-Id'] = userId;
          print('👤 X-User-Id header set: $userId');
        } else {
          print('⚠️ X-User-Id is missing or empty');
        }

        return handler.next(options);
      },
    ));
  }

  // === ОСНОВНОЙ МЕТОД: Получить корзину для конкретного продавца ===
  Future<CartResponse> getSellerCart(String sellerId) async {
    try {
      print('🛒 Getting cart for seller: $sellerId');
      final res = await dio.get('/orders/cart/seller/$sellerId');
      print('🛒 Seller cart response: ${res.data}');
      return CartResponse.fromJson(res.data);
    } on DioException catch (e) {
      print('❌ Seller cart error: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 404) {
        print('🛒 Cart not found for seller, returning empty cart');
        return CartResponse.empty(sellerId: sellerId);
      }
      rethrow;
    }
  }

  // Добавить товар в корзину (бэк сам определит продавца из productId)
  Future<CartResponse> addItemToCart({
    required String productId,
    required double quantity,
  }) async {
    final body = {
      'productId': productId,
      'quantity': quantity,
    };

    print('🛒 Add to cart request: $body');
    final res = await dio.post('/orders/cart/items', data: body);
    print('🛒 Add to cart response: ${res.data}');

    return CartResponse.fromJson(res.data);
  }

  // Удалить товар из корзины
  Future<void> removeItemFromCart(String itemId) async {
    print('🗑️ Removing item $itemId from cart...');
    await dio.delete('/orders/cart/items/$itemId');
    print('🗑️ Item removed successfully');
  }

  // Обновить количество товара
  Future<CartResponse> updateItemQuantity({
    required String itemId,
    required double quantity,
  }) async {
    final body = {'quantity': quantity};

    print('📝 Updating item $itemId quantity to $quantity...');
    final res = await dio.put('/orders/cart/items/$itemId', data: body);
    print('📝 Item updated: ${res.data}');

    return CartResponse.fromJson(res.data);
  }

  // Очистить корзину конкретного продавца
  Future<void> clearSellerCart(String sellerId) async {
    print('🗑️ Clearing cart for seller: $sellerId');
    await dio.delete('/orders/cart/seller/$sellerId');
    print('🗑️ Seller cart cleared successfully');
  }
}

// ============================================
// ОБНОВЛЕННЫЕ МОДЕЛИ ДАННЫХ
// ============================================
class CartResponse {
  final String cartId;
  final String sellerId;
  final List<CartItemResponse> items;
  final double totalAmount;

  CartResponse({
    required this.cartId,
    required this.sellerId,
    required this.items,
    required this.totalAmount,
  });

  // Конструктор для пустой корзины
  static CartResponse empty({required String sellerId}) {
    return CartResponse(
      cartId: '',
      sellerId: sellerId,
      items: [],
      totalAmount: 0.0,
    );
  }

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    print('📦 === PARSING CART RESPONSE START ===');
    print('📦 All JSON keys: ${json.keys.toList()}');
    print('📦 cartId value: ${json['cartId']}');
    print('📦 sellerId value: ${json['sellerId']}');

    final cartId = json['cartId']?.toString() ?? '';

    print('📦 Final cartId: "$cartId"');
    print('📦 === PARSING CART RESPONSE END ===');

    return CartResponse(
      cartId: cartId,
      sellerId: json['sellerId']?.toString() ?? '',
      items: (json['items'] as List?)
          ?.map((e) => CartItemResponse.fromJson(e))
          .toList() ?? [],
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Геттер для количества товаров
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity.toInt());

  Map<String, SellerCartInfo> get sellerInfo => {};
}

class CartItemResponse {
  final String itemId;
  final String productId;
  final String productName;
  final String unit;
  final double price;
  final double quantity;
  final double subtotal;
  final String sellerId;
  final String sellerName;

  CartItemResponse({
    required this.itemId,
    required this.productId,
    required this.productName,
    required this.unit,
    required this.price,
    required this.quantity,
    required this.subtotal,
    required this.sellerId,
    required this.sellerName,
  });

  factory CartItemResponse.fromJson(Map<String, dynamic> json) {
    return CartItemResponse(
      itemId: json['itemId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? 'Товар',
      unit: json['unit']?.toString() ?? 'шт',
      price: json['price'] != null
          ? (json['price'] as num).toDouble()
          : (json['amount'] != null && json['quantity'] != null && json['quantity'] > 0)
          ? (json['amount'] as num).toDouble() / (json['quantity'] as num).toDouble()
          : 0.0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['amount'] as num?)?.toDouble() ?? 0.0,
      sellerId: json['sellerId']?.toString() ?? '',
      sellerName: json['sellerName']?.toString() ?? 'Продавец',
    );
  }
}

class SellerCartInfo {
  final String sellerId;
  final String sellerName;
  final double subtotal;
  final double minOrderAmount;
  final bool meetsMinimum;

  SellerCartInfo({
    required this.sellerId,
    required this.sellerName,
    required this.subtotal,
    required this.minOrderAmount,
    required this.meetsMinimum,
  });

  factory SellerCartInfo.fromJson(Map<String, dynamic> json) {
    return SellerCartInfo(
      sellerId: json['sellerId']?.toString() ?? '',
      sellerName: json['sellerName']?.toString() ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
      meetsMinimum: json['meetsMinimum'] as bool? ?? true,
    );
  }
}