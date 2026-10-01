import '../../models/campaign.dart';
import '../../models/coupon.dart';

List<Campaign> buildSeedCampaigns() {
  final now = DateTime.now();
  return [
    Campaign(
      id: 'seed-campaign-1',
      name: 'Hafta Sonu İndirimi',
      description: 'Seçili ürünlerde hafta sonuna özel indirim.',
      discountPercent: 15,
      startDate: now.subtract(const Duration(days: 1)),
      endDate: now.add(const Duration(days: 5)),
    ),
  ];
}

List<Coupon> buildSeedCoupons() {
  final now = DateTime.now();
  return [
    Coupon(
      id: 'seed-coupon-1',
      code: 'WELCOME10',
      discountPercent: 10,
      usageLimit: 100,
      usedCount: 12,
      createdAt: now.subtract(const Duration(days: 20)),
    ),
  ];
}
