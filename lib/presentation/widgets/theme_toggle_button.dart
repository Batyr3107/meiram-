import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/presentation/providers/theme_provider.dart';

/// Theme Toggle Button Widget
///
/// Allows users to switch between light and dark themes.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeNotifier = ref.watch(themeModeProvider.notifier);
    final isDark = themeModeNotifier.isDarkMode;

    return IconButton(
      icon: Icon(
        isDark ? Icons.light_mode : Icons.dark_mode,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      tooltip: isDark ? 'Светлая тема' : 'Темная тема',
      onPressed: () async {
        await themeModeNotifier.toggleTheme();
      },
    );
  }
}
