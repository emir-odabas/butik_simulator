import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_mode_provider.dart';
import 'widgets/achievements_section.dart';

/// Profile / settings hub: badges earned so far, plus app settings
/// (dark mode). Store-level stats live on the Dashboard.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const AchievementsSection(),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(Icons.dark_mode_outlined,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(child: Text('Karanlık mod')),
                  Switch(
                    value: themeMode == ThemeMode.dark,
                    onChanged: (isDark) {
                      ref.read(themeModeProvider.notifier).state =
                          isDark ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
