import '../models/coupon.dart';

abstract class CouponRepository {
  Future<List<Coupon>> getAll();
  Future<void> add(Coupon coupon);
  Future<void> update(Coupon coupon);
  Future<void> delete(String id);
}
