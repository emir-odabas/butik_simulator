import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/atelier_colors.dart';
import '../../../../core/design/atelier_typography.dart';
import '../../../../core/design/components/ledger_row.dart';
import '../../../../core/design/components/wax_seal_stamp.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/money.dart';
import '../../../upgrades/application/upgrade_providers.dart';
import '../../../upgrades/domain/upgrade_definitions.dart';

/// "Atölye Tadilat Kontrol Listesi" — a renovation punch-list, not a
/// shop of colored-icon Card tiles. Each upgrade is a checklist line;
/// a finished one gets a [WaxSealStamp] instead of a green checkmark
/// icon in a circle.
class StoreUpgradesSection extends ConsumerWidget {
  const StoreUpgradesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;
    final levelsAsync = ref.watch(upgradeLevelsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ATÖLYE TADİLAT KONTROL LİSTESİ',
          style: theme.textTheme.labelMedium?.copyWith(
            color: atelier.inkMuted,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        levelsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Text('Geliştirmeler yüklenemedi: $error'),
          data: (levels) => Column(
            children: [
              for (var i = 0; i < upgradeDefinitions.length; i++)
                LedgerRow(
                  showDivider: i != upgradeDefinitions.length - 1,
                  child: _UpgradeChecklistLine(
                    definition: upgradeDefinitions[i],
                    currentLevel: levels[upgradeDefinitions[i].id] ?? 0,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UpgradeChecklistLine extends ConsumerWidget {
  const _UpgradeChecklistLine({required this.definition, required this.currentLevel});

  final UpgradeDefinition definition;
  final int currentLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;
    final isMaxed = currentLevel >= definition.maxLevel;
    final nextCost = isMaxed ? null : definition.costForLevel(currentLevel);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isMaxed ? Icons.check_box : Icons.check_box_outline_blank,
          size: 20,
          color: isMaxed ? atelier.thread : atelier.ink,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                definition.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  decoration: isMaxed ? TextDecoration.lineThrough : null,
                  color: isMaxed ? atelier.inkMuted : atelier.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                definition.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isMaxed ? atelier.inkMuted : atelier.ink.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  for (var i = 0; i < definition.maxLevel; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: Icon(
                        Icons.circle,
                        size: 6,
                        color: i < currentLevel ? atelier.gold : atelier.hairline,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        if (isMaxed)
          WaxSealStamp(label: 'Tamamlandı', color: atelier.thread, angle: 0)
        else
          TextButton(
            onPressed: () => _purchase(context, ref),
            child: Text(
              Money.format(nextCost!),
              style: AtelierTypography.ledger(color: atelier.seal, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Future<void> _purchase(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(upgradeLevelsProvider.notifier).upgrade(definition.id);
    if (!context.mounted) return;
    if (result == UpgradePurchaseResult.success) {
      HapticFeedback.mediumImpact();
    }
    final message = switch (result) {
      UpgradePurchaseResult.success => '${definition.title} geliştirildi!',
      UpgradePurchaseResult.insufficientBalance => 'Yetersiz sanal bakiye.',
      UpgradePurchaseResult.maxLevelReached => 'Bu geliştirme zaten maksimum seviyede.',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
