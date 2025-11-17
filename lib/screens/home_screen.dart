import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_buyer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          // AppBar
          SliverAppBar(
            title: const Text('Добро пожаловать на рынок!'),
            centerTitle: true,
            floating: true,
            snap: true,
            backgroundColor: cs.surface.withOpacity(0.95),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // HERO SECTION
                  _HeroSection(colorScheme: cs, textTheme: textTheme),
                  const SizedBox(height: 40),
                  // CTA BUTTONS
                  _CtaSection(colorScheme: cs),
                  const SizedBox(height: 50),
                  // WHY US SECTION - WAREHOUSE
                  _WarehouseAdvantageSection(colorScheme: cs, textTheme: textTheme),
                  const SizedBox(height: 50),
                  // FEATURES
                  _SectionHeader(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Почему выбирают нас',
                    subtitle: 'Всё для вашего удобства и уверенности в качестве',
                    colorScheme: cs,
                  ),
                  const SizedBox(height: 24),
                  _FeaturesGrid(colorScheme: cs, textTheme: textTheme),
                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 20),
                  Text(
                    '© ${DateTime.now().year} Fresh Market • Свежесть гарантирована',
                    style: textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.colorScheme, required this.textTheme});
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.4),
            colorScheme.primary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.shopping_basket_rounded,
              size: 48,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 24),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Рынок свежих\nпродуктов',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Прямо со складов — на ваш стол. Свежесть, контроль качества и честные цены каждый день.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                // Stats Row
                _buildStatsRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(number: '500+', label: 'Товаров'),
        _StatItem(number: '99%', label: 'Довольных\nклиентов'),
        _StatItem(number: '2ч', label: 'Доставка'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number;
  final String label;
  const _StatItem({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          number,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CtaSection extends StatelessWidget {
  const _CtaSection({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Присоединяйтесь к нашему сообществу',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 500;
            final gap = isNarrow ? const SizedBox(height: 12) : const SizedBox(width: 16);
            final registerBtn = FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterBuyerScreen()),
                );
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add_alt_1_rounded),
                  SizedBox(width: 8),
                  Text('Создать аккаунт'),
                ],
              ),
            );
            final loginBtn = OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                side: BorderSide(color: colorScheme.primary),
                foregroundColor: colorScheme.primary,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.login_rounded),
                  SizedBox(width: 8),
                  Text('Войти'),
                ],
              ),
            );
            if (isNarrow) {
              return Column(
                children: [registerBtn, gap, loginBtn],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [registerBtn, gap, loginBtn],
            );
          }),
        ],
      ),
    );
  }
}

class _WarehouseAdvantageSection extends StatelessWidget {
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _WarehouseAdvantageSection({
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.08),
            colorScheme.primaryContainer.withOpacity(0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warehouse_rounded,
                  color: colorScheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Покупайте напрямую со складов',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Без посредников и переплат',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _AdvantageItem(
            icon: Icons.trending_down_rounded,
            title: 'На 30% выгоднее',
            description: 'Минимальная наценка благодаря прямой закупке со складов производителей',
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 12),
          _AdvantageItem(
            icon: Icons.check_circle_rounded,
            title: 'Гарантированная свежесть',
            description: 'Товары приходят прямо с холодильников производителя на ваш стол',
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 12),
          _AdvantageItem(
            icon: Icons.visibility_rounded,
            title: 'Полная прозрачность',
            description: 'Видите реальную цену, сроки хранения и состав каждого товара',
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 12),
          _AdvantageItem(
            icon: Icons.flash_on_rounded,
            title: 'Оптовые объёмы',
            description: 'Готовы работать как с малым, так и с крупным заказом — всегда выгодно',
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

class _AdvantageItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _AdvantageItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colorScheme.primary, size: 28),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FeaturesGrid extends StatelessWidget {
  const _FeaturesGrid({required this.colorScheme, required this.textTheme});
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final features = const [
      (
      Icons.storefront_rounded,
      'Поставки со складов',
      'Свежие и проверенные продукты с наших складов',
      Icons.verified_rounded
      ),
      (
      Icons.local_shipping_rounded,
      'Быстрая доставка',
      'Доставим за 2 часа по городу в удобное время',
      Icons.timer_rounded
      ),
      (
      Icons.eco_rounded,
      'Натурально и вкусно',
      'Тщательно отбираем поставщиков и продукцию',
      Icons.favorite_rounded
      ),
      (
      Icons.price_check_rounded,
      'Честные цены',
      'Прозрачная цена без скрытых наценок',
      Icons.visibility_rounded
      ),
    ];
    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth >= 900
          ? 4
          : constraints.maxWidth >= 600
          ? 2
          : 1;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.7,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final (icon, title, description, badgeIcon) = features[index];
          return _FeatureCard(
            icon: icon,
            title: title,
            description: description,
            badgeIcon: badgeIcon,
            colorScheme: colorScheme,
            textTheme: textTheme,
          );
        },
      );
    });
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final IconData badgeIcon;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.badgeIcon,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon with background
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.15),
                        colorScheme.primaryContainer.withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: colorScheme.primary, size: 28),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          // Badge
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(badgeIcon, size: 16, color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}