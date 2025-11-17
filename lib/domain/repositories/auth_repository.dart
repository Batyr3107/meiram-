import 'package:shop_app/dto/auth_response.dart';
import 'package:shop_app/dto/registration_response.dart';

/// Authentication repository interface
/// 
/// Defines contract for authentication operations.
/// Implementation can be replaced for testing or different backends.
/// 
/// Example implementation:
/// ```dart
/// class AuthRepositoryImpl implements IAuthRepository {
///   @override
///   Future<AuthResponse> login(String email, String password) async {
///     // Implementation using API
///   }
/// }
/// ```
abstract class IAuthRepository {
  /// Login with email and password
  Future<AuthResponse> login(String email, String password);

  /// Register new buyer
  Future<RegistrationResponse> registerBuyer({
    required String email,
    required String password,
    required String phone,
  });

  /// Refresh access token
  Future<AuthResponse> refreshToken(String refreshToken);

  /// Logout and clear tokens
  Future<void> logout(String refreshToken);

  /// Check if user is authenticated
  bool isAuthenticated();

  /// Get current user ID
  String? getUserId();

  /// Get current user email
  String? getUserEmail();
}
