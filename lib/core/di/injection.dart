import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shop_app/api/address_api.dart';
import 'package:shop_app/api/auth_api.dart';
import 'package:shop_app/api/cart_api.dart';
import 'package:shop_app/api/order_api.dart';
import 'package:shop_app/api/product_api.dart';
import 'package:shop_app/api/seller_api.dart';
import 'package:shop_app/data/repositories/address_repository_impl.dart';
import 'package:shop_app/data/repositories/auth_repository_impl.dart';
import 'package:shop_app/data/repositories/cart_repository_impl.dart';
import 'package:shop_app/data/repositories/order_repository_impl.dart';
import 'package:shop_app/data/repositories/product_repository_impl.dart';
import 'package:shop_app/data/repositories/seller_repository_impl.dart';
import 'package:shop_app/domain/repositories/address_repository.dart';
import 'package:shop_app/domain/repositories/auth_repository.dart';
import 'package:shop_app/domain/repositories/cart_repository.dart';
import 'package:shop_app/domain/repositories/order_repository.dart';
import 'package:shop_app/domain/repositories/product_repository.dart';
import 'package:shop_app/domain/repositories/seller_repository.dart';

final getIt = GetIt.instance;

/// Configure dependency injection
///
/// Call this method in main() before runApp()
@InjectableInit()
Future<void> configureDependencies() async {
  // Register API Clients
  getIt.registerLazySingleton<AuthApi>(() => AuthApi());
  getIt.registerLazySingleton<ProductApi>(() => ProductApi());
  getIt.registerLazySingleton<CartApi>(() => CartApi());
  getIt.registerLazySingleton<OrderApi>(() => OrderApi());
  getIt.registerLazySingleton<SellerApi>(() => SellerApi());
  getIt.registerLazySingleton<AddressApi>(() => AddressApi());

  // Register Repositories
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthApi>()),
  );
  getIt.registerLazySingleton<IProductRepository>(
    () => ProductRepositoryImpl(getIt<ProductApi>()),
  );
  getIt.registerLazySingleton<ICartRepository>(
    () => CartRepositoryImpl(getIt<CartApi>()),
  );
  getIt.registerLazySingleton<IOrderRepository>(
    () => OrderRepositoryImpl(getIt<OrderApi>()),
  );
  getIt.registerLazySingleton<ISellerRepository>(
    () => SellerRepositoryImpl(getIt<SellerApi>()),
  );
  getIt.registerLazySingleton<IAddressRepository>(
    () => AddressRepositoryImpl(getIt<AddressApi>()),
  );
}

/// Reset dependency injection (for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}
