import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/atelier_colors.dart';
import '../../../core/design/components/ledger_page.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/product.dart';
import '../../notifications/application/notification_providers.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../products/application/product_providers.dart';
import '../../store/application/store_providers.dart';
import 'widgets/daily_quests_card.dart';
import 'widgets/diary_notes_section.dart';
import 'widgets/store_cover_header.dart';

/// "Bugünün Sayfası" — the owner's daily notebook page, laid out as a
/// page rather than a dashboard: a chapter cover, then the day's notes
/// written into the margin-ruled page, then a to-do note taped below.
/// The three parts deliberately use three different surfaces (see
/// `store_cover_header.dart`, `diary_notes_section.dart`,
/// `daily_quests_card.dart`).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(storeProfileProvider);
    final productsAsync = ref.watch(productsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(color: atelier.seal, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$unreadCount',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: atelier.onSeal, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: LedgerPage(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text('Bir şeyler ters gitti: $error'),
            ),
          ),
          data: (profile) {
            final products = productsAsync.valueOrNull ?? const <Product>[];
            final activeCount = products.where((p) => p.isActive).length;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StoreCoverHeader(profile: profile),
                  const SizedBox(height: AppSpacing.xl),
                  DiaryNotesSection(
                    profile: profile,
                    activeProductCount: activeCount,
                    totalProductCount: products.length,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  // Nudged off the page's left edge so the taped note
                  // doesn't sit square with everything above it.
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.md, right: 2),
                      child: const DailyQuestsCard(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Kazandığım rozetler Profil sayfasında birikiyor.',
                    style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
