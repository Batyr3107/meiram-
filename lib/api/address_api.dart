import 'package:dio/dio.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/network/auth_interceptor.dart';
import 'package:shop_app/core/network/dio_client.dart';

/// Address API client
///
/// Handles address management with automatic authentication.
class AddressApi {
  AddressApi() : _client = DioClient() {
    // Add auth interceptor
    _client.dio.interceptors.add(AuthInterceptor());
  }

  final DioClient _client;

  /// Get all buyer addresses
  Future<List<AddressResponse>> getAllAddresses() async {
    AppLogger.debug('Fetching all addresses');

    try {
      final response = await _client.get<List<dynamic>>('/api/v1/addresses');
      final List<AddressResponse> addresses = (response.data as List<dynamic>)
          .map((dynamic e) => AddressResponse.fromJson(e as Map<String, dynamic>))
          .toList();

      AppLogger.debug('Fetched ${addresses.length} addresses');
      return addresses;
    } catch (e, stack) {
      AppLogger.error('Failed to fetch addresses', e, stack);
      rethrow;
    }
  }

  /// Create new address
  Future<AddressResponse> createAddress(String address) async {
    AppLogger.info('Creating new address');

    try {
      final Map<String, dynamic> body = <String, dynamic>{'address': address};
      final response = await _client.post<Map<String, dynamic>>(
        '/api/v1/addresses',
        data: body,
      );

      if (response.data == null) {
        throw Exception('Empty response from server');
      }

      AppLogger.info('Address created successfully');
      return AddressResponse.fromJson(response.data!);
    } catch (e, stack) {
      AppLogger.error('Failed to create address', e, stack);
      rethrow;
    }
  }

  /// Update existing address
  Future<AddressResponse> updateAddress(String id, String address) async {
    AppLogger.info('Updating address: $id');

    try {
      final Map<String, dynamic> body = <String, dynamic>{
        'id': id,
        'address': address,
      };
      final response = await _client.put<Map<String, dynamic>>(
        '/api/v1/addresses',
        data: body,
      );

      if (response.data == null) {
        throw Exception('Empty response from server');
      }

      AppLogger.info('Address updated successfully');
      return AddressResponse.fromJson(response.data!);
    } catch (e, stack) {
      AppLogger.error('Failed to update address $id', e, stack);
      rethrow;
    }
  }

  /// Delete address
  Future<void> deleteAddress(String id) async {
    AppLogger.info('Deleting address: $id');

    try {
      await _client.delete<void>('/api/v1/addresses/$id');
      AppLogger.info('Address deleted successfully');
    } catch (e, stack) {
      AppLogger.error('Failed to delete address $id', e, stack);
      rethrow;
    }
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
    // Validate required field
    if (json['id'] == null) {
      throw FormatException('Missing required field: id');
    }

    return AddressResponse(
      id: json['id'].toString(),
      address: json['address']?.toString() ?? '',
    );
  }
}