import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/local/local_storage_providers.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/local/local_product_repository.dart';
import '../../../data/repositories/product_repository.dart';

/// The active [ProductRepository] implementation. Swapping to a remote
/// backend later means changing only this provider.
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return LocalProductRepository(ref.watch(localStorageServiceProvider));
});

/// Product catalog state, backed by [productRepositoryProvider].
///
/// Screens call the mutating methods here (add/update/delete/toggle)
/// rather than talking to the repository directly, so all product-list
/// UI stays in sync automatically.
final productsProvider =
    AsyncNotifierProvider<ProductsNotifier, List<Product>>(ProductsNotifier.new);

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() {
    return ref.watch(productRepositoryProvider).getAll();
  }

  Future<void> addProduct(Product product) async {
    await ref.read(productRepositoryProvider).add(product);
    state = await AsyncValue.guard(
      () => ref.read(productRepositoryProvider).getAll(),
    );
  }

  Future<void> updateProduct(Product product) async {
    await ref.read(productRepositoryProvider).update(product);
    state = await AsyncValue.guard(
      () => ref.read(productRepositoryProvider).getAll(),
    );
  }

  Future<void> deleteProduct(String id) async {
    await ref.read(productRepositoryProvider).delete(id);
    state = await AsyncValue.guard(
      () => ref.read(productRepositoryProvider).getAll(),
    );
  }

  Future<void> toggleActive(Product product) {
    return updateProduct(product.copyWith(isActive: !product.isActive));
  }
}
