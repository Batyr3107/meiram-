import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/core/error/app_error.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/domain/usecases/login_usecase.dart';
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

  // Используем DI для получения use case
  late final LoginUseCase _loginUseCase;

  @override
  void initState() {
    super.initState();
    // Получаем LoginUseCase через DI
    _loginUseCase = getIt<LoginUseCase>();
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

  Widget _buildHeader(BuildContext context, ColorScheme cs, TextTheme textTheme) {
    return Column(
      children: [
        // Иконка в круге с градиентом
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, cs.primary.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.login_rounded,
            size: 40,
            color: cs.onPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'С возвращением!',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Войдите, чтобы продолжить покупки',
          style: textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
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
      // Используем LoginUseCase вместо прямого API вызова
      final res = await _loginUseCase.execute(
        _emailCtrl.text.trim(),
        _pwdCtrl.text,
      );

      if (!mounted) return;

      AppLogger.info('Login successful, userId: ${res.userId}');

      await AuthService.saveTokens(res);

      AppLogger.info('Tokens saved successfully');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );

    } on ValidationError catch (e) {
      // Обработка ошибок валидации
      if (!mounted) return;

      if (e.message.contains('email')) {
        setState(() => _emailError = 'Неверный формат email');
      } else if (e.message.contains('password')) {
        setState(() => _passwordError = 'Пароль должен содержать минимум 6 символов');
      }

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
      resizeToAvoidBottomInset: true,
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Вход'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: cs.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Красивый заголовок с иконкой
                _buildHeader(context, cs, t.textTheme),
                const SizedBox(height: 32),

                // Красивая форма в карточке
                Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: cs.outline.withOpacity(0.1),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Email поле
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _emailCtrl,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'example@mail.com',
                              filled: true,
                              fillColor: cs.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: cs.outline.withOpacity(0.2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _emailError != null ? cs.error : cs.outline.withOpacity(0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _emailError != null ? cs.error : cs.primary,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(Icons.email_rounded, color: cs.primary),
                              errorText: null,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _clearErrors(),
                          ),
                          if (_emailError != null) ...[
                            const SizedBox(height: 8),
                            _ErrorText(text: _emailError!),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Password поле
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _pwdCtrl,
                            decoration: InputDecoration(
                              labelText: 'Пароль',
                              filled: true,
                              fillColor: cs.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: cs.outline.withOpacity(0.2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _passwordError != null ? cs.error : cs.outline.withOpacity(0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _passwordError != null ? cs.error : cs.primary,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(Icons.lock_rounded, color: cs.primary),
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
                            const SizedBox(height: 8),
                            _ErrorText(text: _passwordError!),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Запомнить меня + Забыли пароль
                Row(
                  children: [
                    Transform.scale(
                      scale: 0.9,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() => _rememberMe = value ?? false);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Text(
                      'Запомнить меня',
                      style: t.textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Функция восстановления пароля скоро будет доступна'),
                            backgroundColor: cs.primary,
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(
                        'Забыли пароль?',
                        style: t.textTheme.bodySmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Кнопка входа с градиентом
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.primary.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _loading ? null : _submit,
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: _loading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: cs.onPrimary,
                                ),
                              )
                            : Text(
                                'Войти',
                                style: t.textTheme.titleMedium?.copyWith(
                                  color: cs.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Разделитель
                Row(
                  children: [
                    Expanded(child: Divider(color: cs.outline.withOpacity(0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'или',
                        style: t.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: cs.outline.withOpacity(0.3))),
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
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Зарегистрируйтесь',
                        style: t.textTheme.bodyMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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