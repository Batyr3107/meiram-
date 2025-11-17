import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/domain/repositories/auth_repository.dart';
import 'package:shop_app/domain/usecases/login_usecase.dart';
import 'package:shop_app/domain/usecases/register_buyer_usecase.dart';
import 'package:shop_app/dto/auth_response.dart';
import 'package:shop_app/dto/registration_response.dart';

/// Auth Repository Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return getIt<IAuthRepository>();
});

/// Login Use Case Provider
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

/// Register Buyer Use Case Provider
final registerBuyerUseCaseProvider = Provider<RegisterBuyerUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterBuyerUseCase(repository);
});

/// Auth State Provider - manages authentication state
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier();
});

/// Auth State
class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user = null,
    this.error = null,
  });

  final bool isAuthenticated;
  final bool isLoading;
  final AuthResponse? user;
  final String? error;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    AuthResponse? user,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

/// Auth State Notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(const AuthState());

  void setAuthenticated(AuthResponse user) {
    state = state.copyWith(
      isAuthenticated: true,
      user: user,
      isLoading: false,
      error: null,
    );
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String error) {
    state = state.copyWith(
      error: error,
      isLoading: false,
    );
  }

  void logout() {
    state = const AuthState();
  }
}
