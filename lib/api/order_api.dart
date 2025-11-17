import 'package:dio/dio.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/network/dio_client.dart';
import 'package:shop_app/services/auth_service.dart';

/// Order API client
///
/// Handles order management with automatic authentication.
class OrderApi {
  OrderApi() : _client = DioClient() {
    _client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
          final String? token = await AuthService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          final String? userId = await AuthService.getUserId();
          if (userId != null) {
            options.headers['X-User-Id'] = userId;
          }
          handler.next(options);
        },
      ),
    );
  }

  final DioClient _client;

  /// Submit order from cart
  Future<CreateOrderResponse> submitOrder({
    required String cartId,
    String? comment,
    String? deliveryAddress,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'cartId': cartId,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
      if (deliveryAddress != null && deliveryAddress.isNotEmpty)
        'deliveryAddress': deliveryAddress,
    };

    AppLogger.info('Submitting order from cart: $cartId');

    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/orders/submit',
        data: body,
      );

      AppLogger.info('Order submitted successfully');
      return CreateOrderResponse.fromJson(response.data!);
    } catch (e, stack) {
      AppLogger.error('Failed to submit order', e, stack);
      rethrow;
    }
  }

  /// Get buyer's orders with pagination
  Future<OrdersPageResponse> getBuyerOrders({
    int page = 0,
    int size = 20,
  }) async {
    AppLogger.debug('Fetching buyer orders: page=$page, size=$size');

    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/orders',
        queryParameters: <String, dynamic>{
          'page': page,
          'size': size,
        },
      );

      AppLogger.debug('Fetched ${response.data!['content'].length} orders');
      return OrdersPageResponse.fromJson(response.data!);
    } catch (e, stack) {
      AppLogger.error('Failed to fetch buyer orders', e, stack);
      rethrow;
    }
  }

  /// Get order details by ID
  Future<BuyerOrderDetailResponse> getOrderDetails(String orderId) async {
    AppLogger.debug('Fetching order details: $orderId');

    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/orders/$orderId',
      );

      AppLogger.debug('Order details retrieved');
      return BuyerOrderDetailResponse.fromJson(response.data!);
    } catch (e, stack) {
      AppLogger.error('Failed to fetch order details $orderId', e, stack);
      rethrow;
    }
  }
}

// ============================================
// CreateOrderResponse - ответ на создание заказа
// ============================================
class CreateOrderResponse {
  final String orderId;
  final String status;
  final double amount;
  final DateTime createdAt;

  CreateOrderResponse({
    required this.orderId,
    required this.status,
    required this.amount,
    required this.createdAt,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      orderId: json['orderId'].toString(),
      status: json['status']?.toString() ?? 'PENDING',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

// ============================================
// OrdersPageResponse - пагинация списка заказов
// ============================================
class OrdersPageResponse {
  final List<BuyerOrderResponse> content;
  final int totalPages;
  final int totalElements;

  OrdersPageResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
  });

  factory OrdersPageResponse.fromJson(Map<String, dynamic> json) {
    return OrdersPageResponse(
      content: (json['content'] as List?)
          ?.map((e) => BuyerOrderResponse.fromJson(e))
          .toList() ?? [],
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
    );
  }
}

// ============================================
// BuyerOrderResponse - краткая инфо в списке
// ============================================
class BuyerOrderResponse {
  final String orderId;
  final String sellerName;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final int itemsCount;

  BuyerOrderResponse({
    required this.orderId,
    required this.sellerName,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.itemsCount,
  });

  factory BuyerOrderResponse.fromJson(Map<String, dynamic> json) {
    return BuyerOrderResponse(
      orderId: json['orderId'].toString(),
      sellerName: json['sellerName']?.toString() ?? 'Продавец',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      itemsCount: (json['itemsCount'] as int?) ?? 0,
    );
  }
}

// ============================================
// BuyerOrderDetailResponse - детальная информация о заказе
// ============================================
class BuyerOrderDetailResponse {
  final String id;
  final String status;
  final double amount;
  final String deliveryType;
  final String? deliveryAddress;
  final String? comment;
  final List<OrderItemDetail> items;
  final DateTime createdAt; // ← ДОБАВЛЕНО: дата создания

  BuyerOrderDetailResponse({
    required this.id,
    required this.status,
    required this.amount,
    required this.deliveryType,
    this.deliveryAddress,
    this.comment,
    required this.items,
    required this.createdAt,
  });

  factory BuyerOrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return BuyerOrderDetailResponse(
      id: json['id'].toString(),
      status: json['status']?.toString() ?? 'PENDING',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      deliveryType: json['deliveryType']?.toString() ?? 'PICKUP',
      deliveryAddress: json['deliveryAddress']?.toString(),
      comment: json['comment']?.toString(),
      items: (json['items'] as List?)
          ?.map((e) => OrderItemDetail.fromJson(e))
          .toList() ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Геттеры для совместимости с orders_screen.dart
  String get orderId => id;
  double get totalAmount => amount;
}

// ============================================
// OrderItemDetail - товар в заказе (ПОЛНАЯ ВЕРСИЯ)
// ============================================
class OrderItemDetail {
  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  final double price;
  final double amount;
  final String sellerName;

  OrderItemDetail({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.amount,
    required this.sellerName,
  });

  factory OrderItemDetail.fromJson(Map<String, dynamic> json) {
    return OrderItemDetail(
      productId: json['productId'].toString(),
      productName: json['productName']?.toString() ?? 'Товар',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? 'шт',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      sellerName: json['sellerName']?.toString() ?? 'Продавец',
    );
  }

  // Геттер для совместимости с orders_screen.dart
  double get subtotal => amount;
}