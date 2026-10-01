import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/local/local_storage_providers.dart';
import '../../../data/models/coupon.dart';
import '../../../data/repositories/coupon_repository.dart';
import '../../../data/repositories/local/local_coupon_repository.dart';

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  return LocalCouponRepository(ref.watch(localStorageServiceProvider));
});

final couponsProvider =
    AsyncNotifierProvider<CouponsNotifier, List<Coupon>>(CouponsNotifier.new);

class CouponsNotifier extends AsyncNotifier<List<Coupon>> {
  @override
  Future<List<Coupon>> build() {
    return ref.watch(couponRepositoryProvider).getAll();
  }

  Future<void> addCoupon(Coupon coupon) async {
    await ref.read(couponRepositoryProvider).add(coupon);
    state = await AsyncValue.guard(() => ref.read(couponRepositoryProvider).getAll());
  }

  Future<void> deleteCoupon(String id) async {
    await ref.read(couponRepositoryProvider).delete(id);
    state = await AsyncValue.guard(() => ref.read(couponRepositoryProvider).getAll());
  }

  Future<void> toggleActive(Coupon coupon) async {
    await ref.read(couponRepositoryProvider).update(coupon.copyWith(isActive: !coupon.isActive));
    state = await AsyncValue.guard(() => ref.read(couponRepositoryProvider).getAll());
  }
}
