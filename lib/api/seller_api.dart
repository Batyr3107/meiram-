import 'package:dio/dio.dart';
import '../services/auth_service.dart';

class SellerApi {
  final Dio dio;

  SellerApi(String baseUrl) : dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    // Добавляем интерцептор для автоматической подстановки токена
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<SellerListResponse> getActiveSellers({int page = 0, int size = 20}) async {
    final res = await dio.get('/clients/sellers', queryParameters: {
      'page': page,
      'size': size,
    });
    return SellerListResponse.fromJson(res.data);
  }

  Future<SellerResponse> getSellerById(String sellerId) async {
    final res = await dio.get('/clients/sellers/$sellerId');
    return SellerResponse.fromJson(res.data);
  }
}

class SellerListResponse {
  final List<SellerResponse> content;
  final int totalPages;
  final int totalElements;
  final int size;
  final int number;

  SellerListResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.number,
  });

  factory SellerListResponse.fromJson(Map<String, dynamic> json) {
    return SellerListResponse(
      content: (json['content'] as List)
          .map((item) => SellerResponse.fromJson(item))
          .toList(),
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
      size: json['size'] as int,
      number: json['number'] as int,
    );
  }
}

class SellerResponse {
  final String id;
  final String organizationName;
  final String bin;
  final String description;
  final double minOrderAmount;
  final String status;

  SellerResponse({
    required this.id,
    required this.organizationName,
    required this.bin,
    required this.description,
    required this.minOrderAmount,
    required this.status,
  });

  factory SellerResponse.fromJson(Map<String, dynamic> json) {
    return SellerResponse(
      id: json['id'].toString(),
      organizationName: json['organizationName'] as String? ?? 'Неизвестный продавец',
      bin: json['bin'] as String? ?? '',
      description: json['description'] as String? ?? '',
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }
}