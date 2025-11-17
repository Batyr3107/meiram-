import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/theme/app_theme.dart';
import 'package:shop_app/presentation/providers/theme_provider.dart';
import 'screens/auth_wrapper.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dependency Injection
  await configureDependencies();
  AppLogger.info('Dependency Injection configured');

  // Load auth tokens
  await AuthService.ensureLoaded();
  AppLogger.info('Auth service initialized');

  runApp(
    const ProviderScope(
      child: ShopApp(),
    ),
  );
}

class ShopApp extends ConsumerWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Рынок продуктов',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}






