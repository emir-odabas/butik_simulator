import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/local/local_storage_providers.dart';
import '../../../data/models/campaign.dart';
import '../../../data/repositories/campaign_repository.dart';
import '../../../data/repositories/local/local_campaign_repository.dart';

final campaignRepositoryProvider = Provider<CampaignRepository>((ref) {
  return LocalCampaignRepository(ref.watch(localStorageServiceProvider));
});

final campaignsProvider =
    AsyncNotifierProvider<CampaignsNotifier, List<Campaign>>(CampaignsNotifier.new);

class CampaignsNotifier extends AsyncNotifier<List<Campaign>> {
  @override
  Future<List<Campaign>> build() {
    return ref.watch(campaignRepositoryProvider).getAll();
  }

  Future<void> addCampaign(Campaign campaign) async {
    await ref.read(campaignRepositoryProvider).add(campaign);
    state = await AsyncValue.guard(() => ref.read(campaignRepositoryProvider).getAll());
  }

  Future<void> updateCampaign(Campaign campaign) async {
    await ref.read(campaignRepositoryProvider).update(campaign);
    state = await AsyncValue.guard(() => ref.read(campaignRepositoryProvider).getAll());
  }

  Future<void> deleteCampaign(String id) async {
    await ref.read(campaignRepositoryProvider).delete(id);
    state = await AsyncValue.guard(() => ref.read(campaignRepositoryProvider).getAll());
  }

  Future<void> toggleEnabled(Campaign campaign) {
    return updateCampaign(campaign.copyWith(isEnabled: !campaign.isEnabled));
  }
}
