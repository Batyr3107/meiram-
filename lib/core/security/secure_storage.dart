import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop_app/core/logger/app_logger.dart';

/// Secure storage wrapper for sensitive data
/// 
/// Uses platform-specific secure storage:
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences
/// - Web: Encrypted localStorage
/// 
/// Usage:
/// ```dart
/// final storage = SecureStorage();
/// await storage.write('token', 'my_secret_token');
/// final token = await storage.read('token');
/// ```
class SecureStorage {
  SecureStorage() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  final FlutterSecureStorage _storage;

  /// Write secure data
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      AppLogger.debug('Secure write: $key');
    } catch (e, stack) {
      AppLogger.error('Failed to write secure data', e, stack);
      rethrow;
    }
  }

  /// Read secure data
  Future<String?> read(String key) async {
    try {
      final String? value = await _storage.read(key: key);
      AppLogger.debug('Secure read: $key');
      return value;
    } catch (e, stack) {
      AppLogger.error('Failed to read secure data', e, stack);
      return null;
    }
  }

  /// Delete secure data
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      AppLogger.debug('Secure delete: $key');
    } catch (e, stack) {
      AppLogger.error('Failed to delete secure data', e, stack);
    }
  }

  /// Delete all secure data
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      AppLogger.warning('All secure data deleted');
    } catch (e, stack) {
      AppLogger.error('Failed to delete all secure data', e, stack);
    }
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      return false;
    }
  }

  /// Read all keys
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e, stack) {
      AppLogger.error('Failed to read all secure data', e, stack);
      return <String, String>{};
    }
  }
}
