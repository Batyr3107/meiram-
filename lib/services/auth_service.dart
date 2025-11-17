import 'dart:async';
import 'dart:convert';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:uuid/uuid.dart';
import 'cart_service.dart';
import '../cache/product_cache.dart';

// Для мобильных
import 'package:shared_preferences/shared_preferences.dart';

// Для Web
import 'package:universal_html/html.dart' as html;
import 'dart:io' show Platform;

// Для проверки платформы
import 'package:flutter/foundation.dart' show kIsWeb;

// DTO
import '../dto/auth_response.dart';
import '../api/auth_api.dart';

class AuthService {
  // === ТОКЕНЫ ===
  static String? _accessToken;
  static String? _refreshToken;
  static String? _userId;
  static String? _role;
  static String? _deviceId;

  // === ПРОФИЛЬ ===
  static String _displayName = 'Покупатель';
  static String _email = '';
  static String _phone = '';

  // === СОСТОЯНИЕ ===
  static Completer<void>? _loadCompleter;
  static bool _isLoaded = false;
  static Completer<void>? _refreshCompleter;

  // === КЛЮЧИ ===
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _userRoleKey = 'user_role';
  static const _userEmailKey = 'user_email';
  static const _userNameKey = 'user_name';
  static const _userPhoneKey = 'user_phone';
  static const _deviceIdKey = 'device_id';

  // === ГАРАНТИЯ ЗАГРУЗКИ ===
  static Future<void> ensureLoaded() async {
    if (!_isLoaded) {
      _loadCompleter ??= Completer<void>();
      await _loadTokens();
      await _loadProfileFromStorage();

      // Пробуем обновить токены если есть refreshToken
      if (_refreshToken != null && _refreshToken!.isNotEmpty) {
        await _refreshAccessToken();
      }

      _isLoaded = true;
      _loadCompleter?.complete();
    }
    await _loadCompleter?.future;
  }

  // === ПРОВЕРКА ЛОГИНА ===
  static Future<bool> isLoggedIn() async {
    await ensureLoaded();
    return _accessToken != null && _accessToken!.isNotEmpty;
  }

  // === СОХРАНЕНИЕ ТОКЕНОВ ===
  static Future<void> saveTokens(AuthResponse response) async {
    _accessToken = response.accessToken;
    _refreshToken = response.refreshToken;
    _userId = response.userId;
    _role = response.role;
    _isLoaded = true;

    // Генерируем deviceId если его ещё нет
    if (_deviceId == null || _deviceId!.isEmpty) {
      _deviceId = const Uuid().v4();
    }

    // Сбрасываем профиль — будет загружен заново
    await _clearProfileCache();

    // === ВАЖНО: Загружаем профиль из токена после сохранения ===
    try {
      await _loadUserProfileFromToken();
    } catch (e) {
      AppLogger.warning('Failed to load user profile from token', e);
    }

    if (kIsWeb) {
      // === WEB ===
      html.window.localStorage[_accessTokenKey] = response.accessToken;
      html.window.localStorage[_refreshTokenKey] = response.refreshToken;
      html.window.localStorage[_userIdKey] = response.userId;
      html.window.localStorage[_userRoleKey] = response.role;
      html.window.localStorage[_deviceIdKey] = _deviceId!;
    } else {
      // === МОБИЛЬНЫЕ ===
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_accessTokenKey, [response.accessToken]);
      await prefs.setStringList(_refreshTokenKey, [response.refreshToken]);
      await prefs.setStringList(_userIdKey, [response.userId]);
      await prefs.setStringList(_userRoleKey, [response.role]);
      await prefs.setString(_deviceIdKey, _deviceId!);
    }

    AppLogger.info('Tokens saved and user profile loaded from token');
  }

  // === ЗАГРУЗКА ПРОФИЛЯ ИЗ JWT ТОКЕНА ===
  static Future<void> _loadUserProfileFromToken() async {
    if (_accessToken == null) {
      AppLogger.debug('No access token available for profile loading');
      return;
    }

    try {
      AppLogger.debug('Extracting email from JWT token');

      // Декодируем JWT токен
      final parts = _accessToken!.split('.');
      if (parts.length != 3) {
        AppLogger.warning('Invalid JWT token format');
        return;
      }

      final payload = parts[1];
      // Добавляем padding если нужно
      String normalizedPayload = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalizedPayload));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      // Извлекаем email из subject токена
      final email = payloadMap['sub'] as String?;
      if (email != null && email.isNotEmpty) {
        _email = email;
        _displayName = email.split('@').first;

        // Сохраняем в кэш
        if (kIsWeb) {
          html.window.localStorage[_userEmailKey] = _email;
          html.window.localStorage[_userNameKey] = _displayName;
        } else {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userEmailKey, _email);
          await prefs.setString(_userNameKey, _displayName);
        }

        AppLogger.info('User profile loaded from token: email=$_email, name=$_displayName');
      } else {
        AppLogger.warning('Email not found in JWT token');
      }
    } catch (e) {
      AppLogger.error('Failed to decode JWT token', e);
    }
  }

  // === ЗАГРУЗКА ТОКЕНОВ ===
  static Future<void> _loadTokens() async {
    if (kIsWeb) {
      _accessToken = html.window.localStorage[_accessTokenKey];
      _refreshToken = html.window.localStorage[_refreshTokenKey];
      _userId = html.window.localStorage[_userIdKey];
      _role = html.window.localStorage[_userRoleKey];
      _deviceId = html.window.localStorage[_deviceIdKey];
    } else {
      final prefs = await SharedPreferences.getInstance();
      final accessList = prefs.getStringList(_accessTokenKey);
      final refreshList = prefs.getStringList(_refreshTokenKey);
      final userIdList = prefs.getStringList(_userIdKey);
      final roleList = prefs.getStringList(_userRoleKey);

      _accessToken = accessList?.firstOrNull;
      _refreshToken = refreshList?.firstOrNull;
      _userId = userIdList?.firstOrNull;
      _role = roleList?.firstOrNull;
      _deviceId = prefs.getString(_deviceIdKey);
    }

    // Если deviceId не сохранён, создаём новый
    if (_deviceId == null || _deviceId!.isEmpty) {
      _deviceId = const Uuid().v4();
      await _saveDeviceId();
    }
  }

  // === СОХРАНЕНИЕ DEVICE ID ===
  static Future<void> _saveDeviceId() async {
    if (_deviceId == null || _deviceId!.isEmpty) return;

    if (kIsWeb) {
      html.window.localStorage[_deviceIdKey] = _deviceId!;
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_deviceIdKey, _deviceId!);
    }
  }

  // === ОБНОВЛЕНИЕ ACCESS ТОКЕНА ===
  static Future<bool> _refreshAccessToken() async {
    // Если уже идёт рефреш — ждём его результат
    if (_refreshCompleter != null) {
      await _refreshCompleter!.future;
      return _accessToken != null && _accessToken!.isNotEmpty;
    }

    _refreshCompleter = Completer<void>();

    try {
      if (_refreshToken == null || _refreshToken!.isEmpty) {
        await clearTokens();
        _refreshCompleter?.complete();
        _refreshCompleter = null;
        return false;
      }

      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');
      final authApi = AuthApi(baseUrl);

      // Отправляем refreshToken и deviceId, получаем новый accessToken
      final response = await authApi.refresh(
        refreshToken: _refreshToken!,
        deviceId: _deviceId ?? '',
      );

      _accessToken = response.accessToken;
      _refreshToken = response.refreshToken;
      _userId = response.userId;
      _role = response.role;

      // Сохраняем новые токены
      if (kIsWeb) {
        html.window.localStorage[_accessTokenKey] = response.accessToken;
        html.window.localStorage[_refreshTokenKey] = response.refreshToken;
        html.window.localStorage[_userIdKey] = response.userId;
        html.window.localStorage[_userRoleKey] = response.role;
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_accessTokenKey, [response.accessToken]);
        await prefs.setStringList(_refreshTokenKey, [response.refreshToken]);
        await prefs.setStringList(_userIdKey, [response.userId]);
        await prefs.setStringList(_userRoleKey, [response.role]);
      }

      // После обновления токена также обновляем профиль
      await _loadUserProfileFromToken();

      AppLogger.info('Access token successfully refreshed');
      _refreshCompleter?.complete();
      _refreshCompleter = null;
      return true;
    } catch (e) {
      AppLogger.error('Failed to refresh access token', e);
      await clearTokens();
      _refreshCompleter?.complete();
      _refreshCompleter = null;
      return false;
    }
  }

  // === PUBLIC МЕТОД ДЛЯ РЕФРЕША ===
  static Future<bool> refreshAccessToken() async {
    return await _refreshAccessToken();
  }

  // === ОЧИСТКА ===
  static Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _role = null;
    _isLoaded = false;
    _loadCompleter = null;
    _refreshCompleter = null;

    await _clearProfileCache();

    // === ВАЖНО: Очищаем кэш корзин при logout ===
    CartService.clearCache();
    ProductCache.clear();

    if (kIsWeb) {
      html.window.localStorage.remove(_accessTokenKey);
      html.window.localStorage.remove(_refreshTokenKey);
      html.window.localStorage.remove(_userIdKey);
      html.window.localStorage.remove(_userRoleKey);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userRoleKey);
    }
  }

  // === ОЧИСТКА КЭША ПРОФИЛЯ ===
  static Future<void> _clearProfileCache() async {
    _displayName = 'Покупатель';
    _email = '';
    _phone = '';

    if (kIsWeb) {
      html.window.localStorage.remove(_userEmailKey);
      html.window.localStorage.remove(_userNameKey);
      html.window.localStorage.remove(_userPhoneKey);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userPhoneKey);
    }
  }

  // === ЗАГРУЗКА ПРОФИЛЯ ИЗ КЭША ===
  static Future<void> _loadProfileFromStorage() async {
    if (kIsWeb) {
      _email = html.window.localStorage[_userEmailKey] ?? '';
      _displayName = html.window.localStorage[_userNameKey] ?? 'Покупатель';
      _phone = html.window.localStorage[_userPhoneKey] ?? '';
    } else {
      final prefs = await SharedPreferences.getInstance();
      _email = prefs.getString(_userEmailKey) ?? '';
      _displayName = prefs.getString(_userNameKey) ?? 'Покупатель';
      _phone = prefs.getString(_userPhoneKey) ?? '';
    }
  }

  // === ГЕТТЕРЫ ===
  static String? get accessToken => _accessToken;
  static String? get refreshToken => _refreshToken;
  static String? get userId => _userId;
  static String? get role => _role;
  static String get deviceId => _deviceId ?? '';

  static String get displayName => _displayName;
  static String get email => _email;
  static String get phone => _phone;

  // === УДОБНЫЕ МЕТОДЫ ===
  static Future<String?> getAccessToken() async {
    await ensureLoaded();
    return _accessToken;
  }

  static Future<String?> getUserId() async {
    await ensureLoaded();
    return _userId;
  }

  static Future<String> getDeviceId() async {
    await ensureLoaded();
    return _deviceId ?? '';
  }
}

// Вспомогательный метод
extension ListX on List<String> {
  String? get firstOrNull => isEmpty ? null : first;
}