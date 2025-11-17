import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'main_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<bool> _authFuture;

  @override
  void initState() {
    super.initState();
    _authFuture = AuthService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          print('AuthWrapper error: ${snapshot.error}');
          return const HomeScreen();
        }

        final isLoggedIn = snapshot.data ?? false;

        if (isLoggedIn) {
          return const MainScreen(); // ← ГЛАВНЫЙ ЭКРАН С ТУЛБАРОМ
        } else {
          return const HomeScreen(); // ← Лендинг для гостей
        }
      },
    );
  }
}