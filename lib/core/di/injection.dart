import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

/// Dependency Injection container
/// 
/// Provides centralized service location and dependency injection
/// following the Service Locator pattern with GetIt.
/// 
/// Usage:
/// ```dart
/// // Get instance
/// final authService = getIt<AuthService>();
/// 
/// // Register manually (if not using @injectable)
/// getIt.registerSingleton<MyService>(MyService());
/// ```
final GetIt getIt = GetIt.instance;

/// Initialize dependency injection
/// 
/// Call this in main() before runApp():
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await configureDependencies();
///   runApp(MyApp());
/// }
/// ```
@InjectableInit()
Future<void> configureDependencies() async {
  // Manual registrations for critical services
  // Auto-generated registrations will be added by build_runner
  
  // Register core services
  // getIt.registerLazySingleton<AppLogger>(() => AppLogger());
}
