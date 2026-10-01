import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/local/local_storage_providers.dart';
import '../../../data/models/store_profile.dart';
import '../../../data/repositories/local/local_store_repository.dart';
import '../../../data/repositories/store_repository.dart';

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return LocalStoreRepository(ref.watch(localStorageServiceProvider));
});

final storeProfileProvider =
    AsyncNotifierProvider<StoreProfileNotifier, StoreProfile>(
  StoreProfileNotifier.new,
);

class StoreProfileNotifier extends AsyncNotifier<StoreProfile> {
  @override
  Future<StoreProfile> build() {
    return ref.watch(storeRepositoryProvider).get();
  }

  Future<void> updateProfile(StoreProfile profile) async {
    await ref.read(storeRepositoryProvider).save(profile);
    state = AsyncValue.data(profile);
  }

  /// Grants virtual revenue and XP for a completed order.
  Future<void> grantOrderReward({required double revenue, required int xpGain}) async {
    final current = state.valueOrNull ?? await future;
    final leveled = _applyXp(current, xpGain);

    final updated = leveled.copyWith(
      virtualBalance: leveled.virtualBalance + revenue,
      todayRevenue: leveled.todayRevenue + revenue,
      totalRevenue: leveled.totalRevenue + revenue,
      todayOrders: leveled.todayOrders + 1,
    );

    await updateProfile(updated);
  }

  /// Grants XP and virtual coins for claiming a completed daily quest.
  /// Unlike [grantOrderReward], this isn't counted as "sales revenue".
  Future<void> grantQuestReward({required int xpGain, required double coinGain}) async {
    final current = state.valueOrNull ?? await future;
    final leveled = _applyXp(current, xpGain);

    final updated = leveled.copyWith(virtualBalance: leveled.virtualBalance + coinGain);

    await updateProfile(updated);
  }

  /// Spends virtual balance on a store upgrade. Returns `false` without
  /// changing anything if the store can't afford [cost] — callers should
  /// surface that to the user rather than silently going negative.
  ///
  /// [visitorBump]/[ratingBump] let specific upgrades (e.g. "Reklam",
  /// "Müşteri Hizmetleri") nudge a stat immediately so leveling them up
  /// feels tangible; most upgrades leave both at zero for now and exist
  /// purely as a progression sink.
  Future<bool> purchaseUpgrade({
    required double cost,
    int xpGain = 0,
    int visitorBump = 0,
    double ratingBump = 0,
  }) async {
    final current = state.valueOrNull ?? await future;
    if (current.virtualBalance < cost) return false;

    final leveled = _applyXp(current, xpGain);
    final updated = leveled.copyWith(
      virtualBalance: leveled.virtualBalance - cost,
      visitorCount: leveled.visitorCount + visitorBump,
      rating: (leveled.rating + ratingBump).clamp(0, 5).toDouble(),
    );

    await updateProfile(updated);
    return true;
  }

  /// Applies [xpGain] to [profile] and rolls over into one or more level
  /// ups if the XP bar fills. The XP curve gets ~25% longer each level.
  StoreProfile _applyXp(StoreProfile profile, int xpGain) {
    var level = profile.level;
    var xp = profile.xp + xpGain;
    var xpForNextLevel = profile.xpForNextLevel;

    while (xp >= xpForNextLevel) {
      xp -= xpForNextLevel;
      level += 1;
      xpForNextLevel = (xpForNextLevel * 1.25).round();
    }

    return profile.copyWith(level: level, xp: xp, xpForNextLevel: xpForNextLevel);
  }
}
