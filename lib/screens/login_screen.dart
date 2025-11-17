import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import '../api/auth_api.dart';
import 'sellers_screen.dart';
import 'register_buyer_screen.dart';
import '../services/auth_service.dart';
import '../screens/auth_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Для красивого отображения ошибок
  String? _emailError;
  String? _passwordError;

  static const _baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  final _api = AuthApi(_baseUrl);

  @override
  void initState() {
    super.initState();
    if (_baseUrl.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API_BASE_URL не задан. Используй --dart-define=API_BASE_URL=...')),
        );
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });
  }

  // === ПЕРЕВОД ОШИБОК НА РУССКИЙ ===
  String _translateError(String msg) {
    final lower = msg.toLowerCase();

    // Ошибки авторизации
    if (lower.contains('invalid username') || lower.contains('invalid credentials')) {
      return 'Неверный email или пароль';
    }
    if (lower.contains('user not found')) {
      return 'Пользователь не найден';
    }
    if (lower.contains('blocked') || lower.contains('account blocked')) {
      return 'Аккаунт заблокирован';
    }
    if (lower.contains('already exists')) {
      return 'Пользователь уже существует';
    }

    // Ошибки валидации
    if (lower.contains('email')) {
      return 'Неверный формат email';
    }
    if (lower.contains('password') || lower.contains('пароль')) {
      return 'Неверный пароль';
    }

    // Ошибки сети
    if (lower.contains('connection') || lower.contains('timeout')) {
      return 'Ошибка подключения. Проверьте интернет';
    }
    if (lower.contains('server')) {
      return 'Ошибка сервера. Попробуйте позже';
    }

    // Если ничего не подошло, но сообщение есть - показываем его
    return msg.isNotEmpty ? msg : 'Ошибка входа. Попробуйте позже';
  }

  Future<void> _submit() async {
    _clearErrors();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final res = await _api.login(
        email: _emailCtrl.text.trim(),
        password: _pwdCtrl.text,
      );

      if (!mounted) return;

      AppLogger.info('Login successful, userId: ${res.userId}');

      await AuthService.saveTokens(res);

      AppLogger.info('Tokens saved successfully');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );

    } on DioException catch (e) {
      if (!mounted) return;

      // Извлекаем оригинальное сообщение об ошибке
      String msg = 'Ошибка сети';
      final data = e.response?.data;

      if (data is Map) {
        // Проверяем структуру ответа сервера
        if (data['error'] is Map) {
          final error = data['error'] as Map;
          msg = error['message'] ?? error['description'] ?? msg;
        } else if (data['message'] is String) {
          msg = data['message'];
        } else if (data['error'] is String) {
          msg = data['error'];
        }
      }

      // Переводим ошибку на русский
      String russianMsg = _translateError(msg);

      AppLogger.error('Login error: $msg -> $russianMsg');

      // Показываем ошибку
      setState(() => _passwordError = russianMsg);

    } catch (e) {
      if (!mounted) return;
      AppLogger.error('Unexpected login error', e);
      setState(() => _passwordError = 'Ошибка: ${_translateError(e.toString())}');
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
        title: const Text('Вход в аккаунт'),
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
                // Заголовок
                Text(
                  'Войдите в свой аккаунт',
                  style: t.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Введите ваши данные для входа',
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Email поле с красивой ошибкой
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'user@example.com',
                        border: const OutlineInputBorder(),
                        enabledBorder: _emailError != null
                            ? OutlineInputBorder(
                          borderSide: BorderSide(color: cs.error),
                        )
                            : null,
                        focusedBorder: _emailError != null
                            ? OutlineInputBorder(
                          borderSide: BorderSide(color: cs.error, width: 2),
                        )
                            : null,
                        prefixIcon: const Icon(Icons.email_rounded),
                        errorText: null,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => _clearErrors(),
                    ),
                    if (_emailError != null) ...[
                      const SizedBox(height: 4),
                      _ErrorText(text: _emailError!),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Password поле с красивой ошибкой
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _pwdCtrl,
                      decoration: InputDecoration(
                        labelText: 'Пароль',
                        border: const OutlineInputBorder(),
                        enabledBorder: _passwordError != null
                            ? OutlineInputBorder(
                          borderSide: BorderSide(color: cs.error),
                        )
                            : null,
                        focusedBorder: _passwordError != null
                            ? OutlineInputBorder(
                          borderSide: BorderSide(color: cs.error, width: 2),
                        )
                            : null,
                        prefixIcon: const Icon(Icons.lock_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: cs.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        errorText: null,
                      ),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => _clearErrors(),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (_passwordError != null) ...[
                      const SizedBox(height: 4),
                      _ErrorText(text: _passwordError!),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Запомнить меня + Забыли пароль
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                    ),
                    Text(
                      'Запомнить меня',
                      style: t.textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Функция восстановления пароля скоро будет доступна')),
                        );
                      },
                      child: Text(
                        'Забыли пароль?',
                        style: t.textTheme.bodyMedium?.copyWith(
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Кнопка входа
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
                        : const Text(
                      'Войти',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Разделитель
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'или',
                        style: t.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // Ссылка на регистрацию
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Еще нет аккаунта? ',
                      style: t.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: _loading ? null : () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const RegisterBuyerScreen()),
                        );
                      },
                      child: const Text('Зарегистрируйтесь'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Красивый виджет для отображения ошибок
class _ErrorText extends StatelessWidget {
  final String text;

  const _ErrorText({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: cs.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}