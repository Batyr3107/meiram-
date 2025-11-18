import 'package:flutter/material.dart';
import 'package:shop_app/core/utils/responsive_helper.dart';
import '../services/auth_service.dart';
import 'orders_screen.dart';
import 'addresses_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _loadData();
  }

  Future<void> _loadData() async {
    await AuthService.ensureLoaded();

    // Обновляем состояние после загрузки
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _logout() async {
    await AuthService.clearTokens();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Профиль'),
        centerTitle: true,
        backgroundColor: cs.surface.withOpacity(0.95),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: cs.primary),
            );
          }

          return CustomScrollView(
            slivers: [
              // === ПРОФИЛЬ КАРТОЧКА ===
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cs.primaryContainer.withOpacity(0.4),
                          cs.primary.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Аватар
                        Container(
                          width: ResponsiveHelper.iconSize(context, 80),
                          height: ResponsiveHelper.iconSize(context, 80),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                cs.primary,
                                cs.primary.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              // Берем первую букву из email если displayName пустой
                              AuthService.email.isNotEmpty
                                  ? AuthService.email[0].toUpperCase()
                                  : AuthService.displayName.isNotEmpty
                                  ? AuthService.displayName[0].toUpperCase()
                                  : 'П',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: cs.onPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Имя пользователя
                        if (AuthService.displayName.isNotEmpty && AuthService.displayName != "Покупатель")
                          Text(
                            AuthService.displayName,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                        if (AuthService.displayName.isNotEmpty && AuthService.displayName != "Покупатель")
                          const SizedBox(height: 4),
                        // Email - основная информация
                        Text(
                          AuthService.email.isNotEmpty
                              ? AuthService.email
                              : 'Почта не указана',
                          style: textTheme.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Телефон если есть
                        if (AuthService.phone.isNotEmpty)
                          Text(
                            AuthService.phone,
                            style: textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // === МЕНЮ ===
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Аккаунт',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildMenuCard(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Мои заказы',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OrdersScreen(),
                            ),
                          );
                        },
                        cs: cs,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: 8),
                      _buildMenuCard(
                        icon: Icons.location_on_outlined,
                        title: 'Адреса доставки',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddressesScreen(),
                            ),
                          );
                        },
                        cs: cs,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: 8),
                      _buildMenuCard(
                        icon: Icons.favorite_border,
                        title: 'Избранное',
                        onTap: _showSoon,
                        cs: cs,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: 8),
                      _buildMenuCard(
                        icon: Icons.help_outline,
                        title: 'Помощь и поддержка',
                        onTap: _showSoon,
                        cs: cs,
                        textTheme: textTheme,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // === ВЫХОД ===
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildMenuCard(
                    icon: Icons.logout_rounded,
                    title: 'Выйти из аккаунта',
                    onTap: _logout,
                    cs: cs,
                    textTheme: textTheme,
                    isLogout: true,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ColorScheme cs,
    required TextTheme textTheme,
    bool isLogout = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isLogout
                ? Colors.red.withOpacity(0.08)
                : cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLogout
                  ? Colors.red.withOpacity(0.2)
                  : cs.outline.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: ResponsiveHelper.iconSize(context, 44),
                height: ResponsiveHelper.iconSize(context, 44),
                decoration: BoxDecoration(
                  color: isLogout
                      ? Colors.red.withOpacity(0.15)
                      : cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isLogout ? Colors.red : cs.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: isLogout ? Colors.red : cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isLogout
                    ? Colors.red.withOpacity(0.6)
                    : cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Скоро будет'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}