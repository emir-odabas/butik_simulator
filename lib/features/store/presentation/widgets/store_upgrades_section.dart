import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/money.dart';
import '../../../store/application/store_providers.dart';
import '../../../upgrades/application/upgrade_providers.dart';
import '../../../upgrades/domain/upgrade_definitions.dart';

class StoreUpgradesSection extends ConsumerWidget {
  const StoreUpgradesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final levelsAsync = ref.watch(upgradeLevelsProvider);
    final balance = ref.watch(storeProfileProvider).valueOrNull?.virtualBalance ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Mağaza Geliştirmeleri', style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(Money.format(balance), style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Sanal bakiyenle mağazanı geliştir.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            levelsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Text('Geliştirmeler yüklenemedi: $error'),
              data: (levels) => Column(
                children: [
                  for (final def in upgradeDefinitions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _UpgradeRow(definition: def, currentLevel: levels[def.id] ?? 0),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpgradeRow extends ConsumerWidget {
  const _UpgradeRow({required this.definition, required this.currentLevel});

  final UpgradeDefinition definition;
  final int currentLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMaxed = currentLevel >= definition.maxLevel;
    final nextCost = isMaxed ? null : definition.costForLevel(currentLevel);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Icon(definition.icon, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(definition.title, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    for (var i = 0; i < definition.maxLevel; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Icon(
                          Icons.circle,
                          size: 8,
                          color: i < currentLevel
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                        ),
                      ),
                    const SizedBox(width: 6),
                    Text('Seviye $currentLevel/${definition.maxLevel}',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (isMaxed)
            const Icon(Icons.check_circle, color: Colors.green, size: 22)
          else
            OutlinedButton(
              onPressed: () async {
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
              },
              child: Text(Money.format(nextCost!)),
            ),
        ],
      ),
    );
  }
}
