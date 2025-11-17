import 'package:flutter/material.dart';
import 'screens/auth_wrapper.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Загружаем токены и пытаемся их обновить при старте
  await AuthService.ensureLoaded();

  runApp(const ShopApp());
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Рынок продуктов',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const AuthWrapper(), // ← Главная точка входа
      debugShowCheckedModeBanner: false,
    );
  }
}






