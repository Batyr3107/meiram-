import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/api/order_api.dart';
import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/domain/repositories/order_repository.dart';
import 'package:shop_app/domain/usecases/submit_order_usecase.dart';

/// Order Repository Provider
final orderRepositoryProvider = Provider<IOrderRepository>((ref) {
  return getIt<IOrderRepository>();
});

/// Submit Order Use Case Provider
final submitOrderUseCaseProvider = Provider<SubmitOrderUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return SubmitOrderUseCase(repository);
});

/// Orders List Provider
final ordersProvider = FutureProvider.autoDispose<List<BuyerOrderResponse>>((ref) async {
  final repository = ref.watch(orderRepositoryProvider);
  final ordersPage = await repository.getBuyerOrders(page: 0, size: 50);
  return ordersPage.content;
});

/// Order Details Provider
final orderDetailsProvider = FutureProvider.family<BuyerOrderDetailResponse, String>((ref, orderId) async {
  final repository = ref.watch(orderRepositoryProvider);
  return await repository.getOrderDetails(orderId);
});

/// Orders State Provider
final ordersStateProvider = StateNotifierProvider<OrdersStateNotifier, OrdersState>((ref) {
  return OrdersStateNotifier();
});

/// Orders State
class OrdersState {
  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error = null,
    this.hasMore = true,
    this.currentPage = 0,
  });

  final List<BuyerOrderResponse> orders;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  OrdersState copyWith({
    List<BuyerOrderResponse>? orders,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Orders State Notifier
class OrdersStateNotifier extends StateNotifier<OrdersState> {
  OrdersStateNotifier() : super(const OrdersState());

  void setOrders(List<BuyerOrderResponse> orders, {bool hasMore = true}) {
    state = state.copyWith(
      orders: orders,
      hasMore: hasMore,
      isLoading: false,
      error: null,
    );
  }

  void appendOrders(List<BuyerOrderResponse> newOrders, {bool hasMore = true}) {
    state = state.copyWith(
      orders: [...state.orders, ...newOrders],
      hasMore: hasMore,
      isLoading: false,
      currentPage: state.currentPage + 1,
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

  void reset() {
    state = const OrdersState();
  }
}
