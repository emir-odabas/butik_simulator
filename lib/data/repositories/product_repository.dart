import '../models/product.dart';

/// Abstraction over where products are stored.
///
/// The UI and Riverpod notifiers only ever depend on this interface, so
/// swapping [LocalProductRepository] for a future Firebase/Supabase
/// implementation later won't require touching feature code.
abstract class ProductRepository {
  Future<List<Product>> getAll();
  Future<void> add(Product product);
  Future<void> update(Product product);
  Future<void> delete(String id);
}
