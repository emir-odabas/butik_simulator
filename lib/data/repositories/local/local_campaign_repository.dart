import 'dart:convert';

import '../../datasources/local/local_storage_service.dart';
import '../../models/campaign.dart';
import '../campaign_repository.dart';
import 'seed_campaigns_coupons.dart';

class LocalCampaignRepository implements CampaignRepository {
  LocalCampaignRepository(this._storage);

  final LocalStorageService _storage;

  static const _storageKey = 'campaigns';

  @override
  Future<List<Campaign>> getAll() async {
    final raw = _storage.read(_storageKey);
    if (raw == null) {
      final seeded = buildSeedCampaigns();
      await _persist(seeded);
      return seeded;
    }
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => Campaign.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> add(Campaign campaign) async {
    final campaigns = await getAll();
    await _persist([...campaigns, campaign]);
  }

  @override
  Future<void> update(Campaign campaign) async {
    final campaigns = await getAll();
    final updated = [
      for (final c in campaigns)
        if (c.id == campaign.id) campaign else c,
    ];
    await _persist(updated);
  }

  @override
  Future<void> delete(String id) async {
    final campaigns = await getAll();
    await _persist(campaigns.where((c) => c.id != id).toList());
  }

  Future<void> _persist(List<Campaign> campaigns) {
    final encoded = jsonEncode(campaigns.map((c) => c.toJson()).toList());
    return _storage.write(_storageKey, encoded);
  }
}
