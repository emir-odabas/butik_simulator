/// Tracks which daily quests have already been claimed *today*.
///
/// Progress itself is never stored here — it's always recomputed live
/// from the product/order data (see quest_definitions.dart). Only the
/// "already claimed" flag needs persistence, so a claimed quest doesn't
/// hand out its reward twice, and so the flag naturally resets once the
/// calendar day changes.
abstract class QuestRepository {
  Future<Set<String>> getClaimedIdsForToday();
  Future<void> markClaimed(String questId);
}
