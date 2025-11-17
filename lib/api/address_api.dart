import 'package:dio/dio.dart';
import '../services/auth_service.dart';

class AddressApi {
  final Dio dio;

  AddressApi(String baseUrl) : dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        final userId = await AuthService.getUserId();
        if (userId != null) {
          options.headers['X-User-Id'] = userId;
        }
        return handler.next(options);
      },
    ));
  }

  // Получить все адреса покупателя
  Future<List<AddressResponse>> getAllAddresses() async {
    final res = await dio.get('/api/v1/addresses');
    return (res.data as List)
        .map((e) => AddressResponse.fromJson(e))
        .toList();
  }

  // Создать новый адрес
  Future<AddressResponse> createAddress(String address) async {
    final body = {'address': address};
    final res = await dio.post('/api/v1/addresses', data: body);
    return AddressResponse.fromJson(res.data);
  }

  // Обновить адрес
  Future<AddressResponse> updateAddress(String id, String address) async {
    final body = {
      'id': id,
      'address': address,
    };
    final res = await dio.put('/api/v1/addresses', data: body);
    return AddressResponse.fromJson(res.data);
  }

  // Удалить адрес
  Future<void> deleteAddress(String id) async {
    await dio.delete('/api/v1/addresses/$id');
  }
}

// ============================================
// AddressResponse - ответ с адресом
// ============================================
class AddressResponse {
  final String id;
  final String address;

  AddressResponse({
    required this.id,
    required this.address,
  });

  factory AddressResponse.fromJson(Map<String, dynamic> json) {
    return AddressResponse(
      id: json['id'].toString(),
      address: json['address']?.toString() ?? '',
    );
  }
}