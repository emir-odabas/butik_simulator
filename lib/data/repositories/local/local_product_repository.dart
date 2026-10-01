import 'dart:convert';

import '../../datasources/local/local_storage_service.dart';
import '../../models/product.dart';
import '../product_repository.dart';
import 'seed_products.dart';

/// Local, [SharedPreferences]-backed implementation of [ProductRepository].
///
/// Stores the whole product list as a single JSON-encoded string under
/// [_storageKey]. Fine for a catalog of a few dozen products; if the
/// catalog grows much larger this should move to a real local database
/// (e.g. Drift/Isar) behind the same interface.
class LocalProductRepository implements ProductRepository {
  LocalProductRepository(this._storage);

  final LocalStorageService _storage;

  static const _storageKey = 'products';

  @override
  Future<List<Product>> getAll() async {
    final raw = _storage.read(_storageKey);
    if (raw == null) {
      // First launch: seed with demo products so the app never looks
      // empty, and persist them immediately.
      final seeded = buildSeedProducts();
      await _persist(seeded);
      return seeded;
    }

    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> add(Product product) async {
    final products = await getAll();
    await _persist([...products, product]);
  }

  @override
  Future<void> update(Product product) async {
    final products = await getAll();
    final updated = [
      for (final p in products)
        if (p.id == product.id) product else p,
    ];
    await _persist(updated);
  }

  @override
  Future<void> delete(String id) async {
    final products = await getAll();
    final updated = products.where((p) => p.id != id).toList();
    await _persist(updated);
  }

  Future<void> _persist(List<Product> products) {
    final encoded = jsonEncode(products.map((p) => p.toJson()).toList());
    return _storage.write(_storageKey, encoded);
  }
}
