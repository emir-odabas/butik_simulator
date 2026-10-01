import '../models/campaign.dart';

abstract class CampaignRepository {
  Future<List<Campaign>> getAll();
  Future<void> add(Campaign campaign);
  Future<void> update(Campaign campaign);
  Future<void> delete(String id);
}
