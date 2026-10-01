import 'dart:convert';

import '../../datasources/local/local_storage_service.dart';
import '../../models/coupon.dart';
import '../coupon_repository.dart';
import 'seed_campaigns_coupons.dart';

class LocalCouponRepository implements CouponRepository {
  LocalCouponRepository(this._storage);

  final LocalStorageService _storage;

  static const _storageKey = 'coupons';

  @override
  Future<List<Coupon>> getAll() async {
    final raw = _storage.read(_storageKey);
    if (raw == null) {
      final seeded = buildSeedCoupons();
      await _persist(seeded);
      return seeded;
    }
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => Coupon.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> add(Coupon coupon) async {
    final coupons = await getAll();
    await _persist([...coupons, coupon]);
  }

  @override
  Future<void> update(Coupon coupon) async {
    final coupons = await getAll();
    final updated = [
      for (final c in coupons)
        if (c.id == coupon.id) coupon else c,
    ];
    await _persist(updated);
  }

  @override
  Future<void> delete(String id) async {
    final coupons = await getAll();
    await _persist(coupons.where((c) => c.id != id).toList());
  }

  Future<void> _persist(List<Coupon> coupons) {
    final encoded = jsonEncode(coupons.map((c) => c.toJson()).toList());
    return _storage.write(_storageKey, encoded);
  }
}
