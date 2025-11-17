import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/api/product_api.dart';
import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/domain/repositories/product_repository.dart';
import 'package:shop_app/domain/usecases/get_products_usecase.dart';

/// Product Repository Provider
final productRepositoryProvider = Provider<IProductRepository>((ref) {
  return getIt<IProductRepository>();
});

/// Get Products Use Case Provider
final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductsUseCase(repository);
});

/// Products by Seller Provider
final productsBySellerProvider = FutureProvider.family<List<ProductResponse>, String>((ref, sellerId) async {
  final useCase = ref.watch(getProductsUseCaseProvider);
  return await useCase.execute(sellerId);
});

/// Products State Provider
final productsStateProvider = StateNotifierProvider<ProductsStateNotifier, ProductsState>((ref) {
  return ProductsStateNotifier();
});

/// Products State
class ProductsState {
  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.error = null,
    this.selectedSellerId = null,
  });

  final List<ProductResponse> products;
  final bool isLoading;
  final String? error;
  final String? selectedSellerId;

  ProductsState copyWith({
    List<ProductResponse>? products,
    bool? isLoading,
    String? error,
    String? selectedSellerId,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedSellerId: selectedSellerId ?? this.selectedSellerId,
    );
  }
}

/// Products State Notifier
class ProductsStateNotifier extends StateNotifier<ProductsState> {
  ProductsStateNotifier() : super(const ProductsState());

  void setProducts(List<ProductResponse> products, String sellerId) {
    state = state.copyWith(
      products: products,
      selectedSellerId: sellerId,
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
}
