import 'dart:convert';

import '../../datasources/local/local_storage_service.dart';
import '../../models/order.dart';
import '../order_repository.dart';
import 'seed_orders.dart';

class LocalOrderRepository implements OrderRepository {
  LocalOrderRepository(this._storage);

  final LocalStorageService _storage;

  static const _storageKey = 'orders';

  @override
  Future<List<Order>> getAll() async {
    final raw = _storage.read(_storageKey);
    if (raw == null) {
      final seeded = buildSeedOrders();
      await _persist(seeded);
      return seeded;
    }
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> add(Order order) async {
    final orders = await getAll();
    await _persist([order, ...orders]);
  }

  @override
  Future<void> update(Order order) async {
    final orders = await getAll();
    final updated = [
      for (final o in orders)
        if (o.id == order.id) order else o,
    ];
    await _persist(updated);
  }

  Future<void> _persist(List<Order> orders) {
    final encoded = jsonEncode(orders.map((o) => o.toJson()).toList());
    return _storage.write(_storageKey, encoded);
  }
}
