import '../models/store_profile.dart';

/// Abstraction over where the store profile is stored.
abstract class StoreRepository {
  Future<StoreProfile> get();
  Future<void> save(StoreProfile profile);
}
