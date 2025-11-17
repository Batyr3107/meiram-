/// Application-wide constants
class AppConstants {
  // API
  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');
  static const Duration apiTimeout = Duration(seconds: 30);

  // Cache
  static const Duration cacheTimeout = Duration(minutes: 5);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int phoneLength = 11;
  static const int binLength = 12;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // UI
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double iconSize = 24.0;
  static const double avatarSize = 40.0;

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;

  // Local storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String deviceIdKey = 'device_id';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // Error messages
  static const String genericError = 'Произошла ошибка. Попробуйте позже';
  static const String networkError = 'Ошибка сети. Проверьте подключение';
  static const String timeoutError = 'Превышено время ожидания';
  static const String unauthorizedError = 'Необходима авторизация';
}
