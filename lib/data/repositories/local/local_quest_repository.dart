import 'dart:convert';

import 'package:intl/intl.dart';

import '../../datasources/local/local_storage_service.dart';
import '../quest_repository.dart';

class LocalQuestRepository implements QuestRepository {
  LocalQuestRepository(this._storage);

  final LocalStorageService _storage;

  static const _storageKey = 'quest_claims';

  // Plain numeric pattern — no locale data initialization required.
  static String _todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Future<Set<String>> getClaimedIdsForToday() async {
    final raw = _storage.read(_storageKey);
    if (raw == null) return {};

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    if (decoded['date'] != _todayKey()) {
      // A new day has started — yesterday's claims no longer apply.
      return {};
    }
    return (decoded['claimedIds'] as List).cast<String>().toSet();
  }

  @override
  Future<void> markClaimed(String questId) async {
    final current = await getClaimedIdsForToday();
    final updated = {...current, questId};
    await _storage.write(
      _storageKey,
      jsonEncode({'date': _todayKey(), 'claimedIds': updated.toList()}),
    );
  }
}
