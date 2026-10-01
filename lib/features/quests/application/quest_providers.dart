import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/local/local_storage_providers.dart';
import '../../../data/models/app_notification.dart';
import '../../../data/models/order.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/local/local_quest_repository.dart';
import '../../../data/repositories/quest_repository.dart';
import '../../notifications/application/notification_providers.dart';
import '../../orders/application/order_providers.dart';
import '../../products/application/product_providers.dart';
import '../../store/application/store_providers.dart';
import '../domain/quest_definitions.dart';

final questRepositoryProvider = Provider<QuestRepository>((ref) {
  return LocalQuestRepository(ref.watch(localStorageServiceProvider));
});

/// IDs of quests already claimed today. Resets automatically once the
/// calendar day changes (see [LocalQuestRepository]).
final claimedQuestsProvider =
    AsyncNotifierProvider<ClaimedQuestsNotifier, Set<String>>(ClaimedQuestsNotifier.new);

class ClaimedQuestsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() {
    return ref.watch(questRepositoryProvider).getClaimedIdsForToday();
  }

  Future<void> claim(QuestDefinition quest) async {
    final claimed = state.valueOrNull ?? await future;
    if (claimed.contains(quest.id)) return;

    await ref.read(questRepositoryProvider).markClaimed(quest.id);
    state = AsyncValue.data({...claimed, quest.id});

    await ref.read(storeProfileProvider.notifier).grantQuestReward(
          xpGain: quest.xpReward,
          coinGain: quest.coinReward,
        );

    await ref.read(notificationsProvider.notifier).add(
          NotificationType.questCompleted,
          '🎯 Görev tamamlandı',
          '"${quest.title}" görevini tamamladın: +${quest.xpReward} XP',
        );
  }
}

/// A single quest's live progress, ready for the UI.
class QuestProgress {
  const QuestProgress({
    required this.definition,
    required this.current,
    required this.isClaimed,
  });

  final QuestDefinition definition;
  final int current;
  final bool isClaimed;

  bool get isCompleted => current >= definition.target;
}

/// Combines the static quest list with live product/order data and the
/// claimed-today flags into what the dashboard actually renders.
final questProgressProvider = Provider<List<QuestProgress>>((ref) {
  final products = ref.watch(productsProvider).valueOrNull ?? const <Product>[];
  final orders = ref.watch(ordersProvider).valueOrNull ?? const <Order>[];
  final claimed = ref.watch(claimedQuestsProvider).valueOrNull ?? const <String>{};

  return [
    for (final def in dailyQuestDefinitions)
      QuestProgress(
        definition: def,
        current: def.progress(products, orders).clamp(0, def.target),
        isClaimed: claimed.contains(def.id),
      ),
  ];
});
