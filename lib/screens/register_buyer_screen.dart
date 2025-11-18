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
    _confirmPwdCtrl.dispose();
    super.dispose();
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
            Icons.person_add_rounded,
            size: 40,
            color: cs.onPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Создайте аккаунт',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Присоединяйтесь к нашему маркетплейсу',
          style: textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    required String? Function(String?)? validator,
    required ColorScheme cs,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: cs.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        prefixIcon: Icon(icon, color: cs.primary),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?)? validator,
    required ColorScheme cs,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: cs.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        prefixIcon: Icon(icon ?? Icons.lock_rounded, color: cs.primary),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: cs.onSurfaceVariant,
          ),
          onPressed: onToggle,
        ),
      ),
      obscureText: obscure,
      validator: validator,
    );
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
      resizeToAvoidBottomInset: true,
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Регистрация'),
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
                      // Email
                      _buildTextField(
                        controller: _emailCtrl,
                        label: 'Email',
                        hint: 'example@mail.com',
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        cs: cs,
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      _buildTextField(
                        controller: _phoneCtrl,
                        label: 'Телефон',
                        hint: '+77012345678',
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                        cs: cs,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      _buildPasswordField(
                        controller: _pwdCtrl,
                        label: 'Пароль',
                        obscure: _obscurePassword,
                        onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                        validator: _validatePwd,
                        cs: cs,
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      _buildPasswordField(
                        controller: _confirmPwdCtrl,
                        label: 'Подтверждение пароля',
                        obscure: _obscureConfirmPassword,
                        onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        validator: _validateConfirmPwd,
                        cs: cs,
                        icon: Icons.lock_outline_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Register Button с градиентом
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
                                'Зарегистрироваться',
                                style: t.textTheme.titleMedium?.copyWith(
                                  color: cs.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

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

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Уже есть аккаунт? ',
                      style: t.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: _loading ? null : () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Войдите',
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