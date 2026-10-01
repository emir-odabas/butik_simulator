import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/local/local_storage_providers.dart';
import '../../../data/repositories/local/local_upgrade_repository.dart';
import '../../../data/repositories/upgrade_repository.dart';
import '../../store/application/store_providers.dart';
import '../domain/upgrade_definitions.dart';

final upgradeRepositoryProvider = Provider<UpgradeRepository>((ref) {
  return LocalUpgradeRepository(ref.watch(localStorageServiceProvider));
});

/// Current level of every store upgrade, keyed by [UpgradeDefinition.id].
/// An id missing from the map means level 0.
final upgradeLevelsProvider =
    AsyncNotifierProvider<UpgradeLevelsNotifier, Map<String, int>>(UpgradeLevelsNotifier.new);

/// Result of attempting to buy the next level of an upgrade.
enum UpgradePurchaseResult { success, insufficientBalance, maxLevelReached }

class UpgradeLevelsNotifier extends AsyncNotifier<Map<String, int>> {
  @override
  Future<Map<String, int>> build() {
    return ref.watch(upgradeRepositoryProvider).getLevels();
  }

  Future<UpgradePurchaseResult> upgrade(String upgradeId) async {
    final levels = state.valueOrNull ?? await future;
    final definition = upgradeDefinitions.firstWhere((d) => d.id == upgradeId);
    final currentLevel = levels[upgradeId] ?? 0;

    if (currentLevel >= definition.maxLevel) {
      return UpgradePurchaseResult.maxLevelReached;
    }

    final cost = definition.costForLevel(currentLevel);

    // A couple of upgrades nudge a dashboard stat immediately so the
    // purchase feels tangible; the rest are pure progression for now.
    final visitorBump = upgradeId == 'advertising' ? 15 : 0;
    final ratingBump = upgradeId == 'customer_service' ? 0.1 : 0.0;

    final success = await ref.read(storeProfileProvider.notifier).purchaseUpgrade(
          cost: cost,
          xpGain: 15,
          visitorBump: visitorBump,
          ratingBump: ratingBump,
        );

    if (!success) return UpgradePurchaseResult.insufficientBalance;

    final newLevel = currentLevel + 1;
    await ref.read(upgradeRepositoryProvider).setLevel(upgradeId, newLevel);
    state = AsyncValue.data({...levels, upgradeId: newLevel});

    return UpgradePurchaseResult.success;
  }
}
