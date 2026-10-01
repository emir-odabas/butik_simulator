import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/design/atelier_theme.dart';
import '../core/routing/app_router.dart';
import '../core/theme/theme_mode_provider.dart';
import '../data/models/app_notification.dart';
import '../data/models/store_profile.dart';
import '../features/achievements/application/achievement_providers.dart';
import '../features/notifications/application/notification_providers.dart';
import '../features/orders/application/auto_order_service.dart';
import '../features/store/application/store_providers.dart';

/// Root widget of the app. Wires [GoRouter] and the light/dark [ThemeData]
/// together via Riverpod so both can be swapped independently later
/// (e.g. redirects, persisted theme preference) without touching this file.
///
/// Also hosts two app-wide `ref.listen` side effects — level-up and
/// achievement-unlock notifications — here rather than inside
/// `StoreProfileNotifier`/`achievementProgressProvider` themselves, so
/// those stay simple state providers with no dependency on the
/// notifications feature.
class BoutiqueApp extends ConsumerWidget {
  const BoutiqueApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Keep the auto-order timer running for the whole app lifetime.
    ref.watch(autoOrderServiceProvider);

    ref.listen<AsyncValue<StoreProfile>>(storeProfileProvider, (previous, next) {
      final previousLevel = previous?.valueOrNull?.level;
      final nextLevel = next.valueOrNull?.level;
      if (previousLevel != null && nextLevel != null && nextLevel > previousLevel) {
        ref.read(notificationsProvider.notifier).add(
              NotificationType.levelUp,
              '⬆️ Seviye atladın',
              'Mağazan artık Seviye $nextLevel!',
            );
      }
    });

    ref.listen<List<AchievementProgress>>(achievementProgressProvider, (previous, next) {
      if (previous == null) return;
      for (var i = 0; i < next.length && i < previous.length; i++) {
        if (!previous[i].isUnlocked && next[i].isUnlocked) {
          ref.read(notificationsProvider.notifier).add(
                NotificationType.achievementUnlocked,
                '🏆 Yeni rozet kazandın',
                next[i].definition.title,
              );
        }
      }
    });

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AtelierTheme.light(),
      darkTheme: AtelierTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
