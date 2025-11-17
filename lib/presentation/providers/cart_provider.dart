import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/api/cart_api.dart';
import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/domain/repositories/cart_repository.dart';

/// Cart Repository Provider
final cartRepositoryProvider = Provider<ICartRepository>((ref) {
  return getIt<ICartRepository>();
});

/// Cart State Provider - per seller
final cartStateProvider = StateNotifierProvider.family<CartStateNotifier, CartState, String>((ref, sellerId) {
  return CartStateNotifier(sellerId);
});

/// Cart State
class CartState {
  const CartState({
    this.cart = null,
    this.isLoading = false,
    this.error = null,
  });

  final CartResponse? cart;
  final bool isLoading;
  final String? error;

  int get itemCount => cart?.itemCount ?? 0;
  double get totalAmount => cart?.totalAmount ?? 0.0;
  bool get isEmpty => cart == null || cart!.items.isEmpty;

  CartState copyWith({
    CartResponse? cart,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Cart State Notifier
class CartStateNotifier extends StateNotifier<CartState> {
  CartStateNotifier(this.sellerId) : super(const CartState());

  final String sellerId;

  void setCart(CartResponse cart) {
    state = state.copyWith(
      cart: cart,
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

  void clear() {
    state = const CartState();
  }
}
