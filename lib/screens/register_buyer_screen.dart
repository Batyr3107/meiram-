import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/domain/usecases/login_usecase.dart';
import 'package:shop_app/domain/usecases/register_buyer_usecase.dart';
import 'sellers_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../screens/auth_wrapper.dart';

class RegisterBuyerScreen extends StatefulWidget {
  const RegisterBuyerScreen({super.key});
  @override
  State<RegisterBuyerScreen> createState() => _RegisterBuyerScreenState();
}

class _RegisterBuyerScreenState extends State<RegisterBuyerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController(); // Новый контроллер
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Используем DI для получения use cases
  late final RegisterBuyerUseCase _registerUseCase;
  late final LoginUseCase _loginUseCase;

  @override
  void initState() {
    super.initState();
    // Получаем Use Cases через DI
    _registerUseCase = getIt<RegisterBuyerUseCase>();
    _loginUseCase = getIt<LoginUseCase>();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _pwdCtrl.dispose();
    _confirmPwdCtrl.dispose(); // Не забываем освободить
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Введите email';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
    if (!ok) return 'Некорректный email';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.isEmpty) return 'Введите телефон';
    final ok = RegExp(r'^(\+7|8)\d{10}$').hasMatch(v);
    if (!ok) return 'Формат: +7XXXXXXXXXX или 8XXXXXXXXXX';
    return null;
  }

  String? _validatePwd(String? v) {
    if (v == null || v.isEmpty) return 'Введите пароль';
    if (v.length < 6) return 'Минимум 6 символов';
    return null;
  }

  String? _validateConfirmPwd(String? v) {
    if (v == null || v.isEmpty) return 'Подтвердите пароль';
    if (v != _pwdCtrl.text) return 'Пароли не совпадают'; // Проверка совпадения
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // 1. Регистрируем пользователя через Use Case
      final regResponse = await _registerUseCase.execute(
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        password: _pwdCtrl.text,
      );

      AppLogger.info('Registration successful, user ID: ${regResponse.userId}');

      // 2. Автоматически логинимся после регистрации через Use Case
      final loginResponse = await _loginUseCase.execute(
        _emailCtrl.text.trim(),
        _pwdCtrl.text,
      );

      AppLogger.info('Auto-login successful, userId: ${loginResponse.userId}');

      await AuthService.saveTokens(loginResponse);

      AppLogger.info('Tokens saved successfully');

      // 3. Переходим на главный экран
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );

    } on ArgumentError catch (e) {
      // Обработка ошибок валидации из Use Case
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );

    } on DioException catch (e) {
      if (!mounted) return;

      String msg = 'Ошибка сети';
      final data = e.response?.data;
      if (data is Map) {
        if (data['error'] is Map) {
          final error = data['error'] as Map;
          msg = error['message'] ?? error['description'] ?? msg;
        } else if (data['message'] is String) {
          msg = data['message'];
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      AppLogger.error('Registration error', e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация покупателя'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text('Создайте аккаунт покупателя', style: t.textTheme.titleLarge),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'user@example.com',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_rounded),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 12),

                // Phone
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Телефон',
                    hintText: '+7701XXXXXXX или 8701XXXXXXX',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_rounded),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),
                const SizedBox(height: 12),

                // Password
                TextFormField(
                  controller: _pwdCtrl,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: _validatePwd,
                ),
                const SizedBox(height: 12),

                // Confirm Password
                TextFormField(
                  controller: _confirmPwdCtrl,
                  decoration: InputDecoration(
                    labelText: 'Подтверждение пароля',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  validator: _validateConfirmPwd,
                ),
                const SizedBox(height: 20),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _loading
                        ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Зарегистрироваться'),
                  ),
                ),
                const SizedBox(height: 16),

                // Login Link
                TextButton(
                  onPressed: _loading ? null : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('Уже есть аккаунт? Войдите'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}