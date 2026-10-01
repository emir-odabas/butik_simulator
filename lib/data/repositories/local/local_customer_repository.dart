import 'dart:convert';

import '../../datasources/local/local_storage_service.dart';
import '../../models/customer.dart';
import '../customer_repository.dart';
import 'seed_customers.dart';

class LocalCustomerRepository implements CustomerRepository {
  LocalCustomerRepository(this._storage);

  final LocalStorageService _storage;

  static const _storageKey = 'customers';

  @override
  Future<List<Customer>> getAll() async {
    final raw = _storage.read(_storageKey);
    if (raw == null) {
      final seeded = buildSeedCustomers();
      await _persist(seeded);
      return seeded;
    }
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> update(Customer customer) async {
    final customers = await getAll();
    final updated = [
      for (final c in customers)
        if (c.id == customer.id) customer else c,
    ];
    await _persist(updated);
  }

  Future<void> _persist(List<Customer> customers) {
    final encoded = jsonEncode(customers.map((c) => c.toJson()).toList());
    return _storage.write(_storageKey, encoded);
  }
}
