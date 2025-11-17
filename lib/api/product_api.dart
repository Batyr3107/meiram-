import 'package:dio/dio.dart';
import '../services/auth_service.dart';

class ProductResponse {
  final String id;
  final String name;
  final String description;
  final String unit;
  final double price;
  final double minOrderQty;
  final bool active;

  ProductResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
    required this.price,
    required this.minOrderQty,
    required this.active,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> j) {
    return ProductResponse(
      id: j['id'].toString(),
      name: (j['name'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      unit: (j['unit'] ?? '').toString(),
      price: (j['price'] as num?)?.toDouble() ?? 0,
      minOrderQty: (j['minOrderQty'] as num?)?.toDouble() ?? 0,
      active: j['active'] as bool? ?? true,
    );
  }
}

class ProductApi {
  final Dio dio;

  ProductApi(String baseUrl)
      : dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    // тот же интерсептор, что и в SellerApi
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<List<ProductResponse>> getBySeller(String sellerId) async {
    final res = await dio.get('/products/by-seller/$sellerId');
    return (res.data as List)
        .map((e) => ProductResponse.fromJson(e))
        .toList();
  }
}
