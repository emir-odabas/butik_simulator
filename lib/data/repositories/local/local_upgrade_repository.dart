import 'dart:convert';

import '../../datasources/local/local_storage_service.dart';
import '../upgrade_repository.dart';

class LocalUpgradeRepository implements UpgradeRepository {
  LocalUpgradeRepository(this._storage);

  final LocalStorageService _storage;

  static const _storageKey = 'store_upgrades';

  @override
  Future<Map<String, int>> getLevels() async {
    final raw = _storage.read(_storageKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as int));
  }

  @override
  Future<void> setLevel(String upgradeId, int level) async {
    final levels = await getLevels();
    final updated = {...levels, upgradeId: level};
    await _storage.write(_storageKey, jsonEncode(updated));
  }
}
