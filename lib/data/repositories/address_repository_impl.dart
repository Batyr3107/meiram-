import 'package:shop_app/api/address_api.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/performance/performance_monitor.dart';
import 'package:shop_app/core/security/input_sanitizer.dart';
import 'package:shop_app/domain/repositories/address_repository.dart';

/// Address Repository Implementation
class AddressRepositoryImpl implements IAddressRepository {
  AddressRepositoryImpl(this._addressApi);

  final AddressApi _addressApi;

  @override
  Future<List<AddressResponse>> getAllAddresses() async {
    return await PerformanceMonitor.measure('address_repository_get_all', () async {
      AppLogger.debug('AddressRepository: Fetching all addresses');

      try {
        final addresses = await _addressApi.getAllAddresses();
        AppLogger.debug('AddressRepository: Found ${addresses.length} addresses');
        return addresses;
      } catch (e, stack) {
        AppLogger.error('AddressRepository: Failed to fetch addresses', e, stack);
        rethrow;
      }
    });
  }

  @override
  Future<AddressResponse> createAddress(String address) async {
    return await PerformanceMonitor.measure('address_repository_create', () async {
      final sanitizedAddress = InputSanitizer.sanitizeText(address);
      AppLogger.info('AddressRepository: Creating new address');

      try {
        final newAddress = await _addressApi.createAddress(sanitizedAddress);
        AppLogger.info('AddressRepository: Address created successfully');
        return newAddress;
      } catch (e, stack) {
        AppLogger.error('AddressRepository: Failed to create address', e, stack);
        rethrow;
      }
    });
  }

  @override
  Future<AddressResponse> updateAddress(String id, String address) async {
    return await PerformanceMonitor.measure('address_repository_update', () async {
      final sanitizedAddress = InputSanitizer.sanitizeText(address);
      AppLogger.info('AddressRepository: Updating address $id');

      try {
        final updatedAddress = await _addressApi.updateAddress(id, sanitizedAddress);
        AppLogger.info('AddressRepository: Address updated successfully');
        return updatedAddress;
      } catch (e, stack) {
        AppLogger.error('AddressRepository: Failed to update address', e, stack);
        rethrow;
      }
    });
  }

  @override
  Future<void> deleteAddress(String id) async {
    return await PerformanceMonitor.measure('address_repository_delete', () async {
      AppLogger.info('AddressRepository: Deleting address $id');

      try {
        await _addressApi.deleteAddress(id);
        AppLogger.info('AddressRepository: Address deleted successfully');
      } catch (e, stack) {
        AppLogger.error('AddressRepository: Failed to delete address', e, stack);
        rethrow;
      }
    });
  }
}
