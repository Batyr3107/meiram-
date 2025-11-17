import 'package:shop_app/api/address_api.dart';

/// Address Repository Interface
abstract class IAddressRepository {
  /// Get all buyer addresses
  Future<List<AddressResponse>> getAllAddresses();

  /// Create new address
  Future<AddressResponse> createAddress(String address);

  /// Update existing address
  Future<AddressResponse> updateAddress(String id, String address);

  /// Delete address
  Future<void> deleteAddress(String id);
}
