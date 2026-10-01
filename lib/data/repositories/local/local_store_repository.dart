import 'dart:convert';

import '../../../core/constants/app_constants.dart';
import '../../datasources/local/local_storage_service.dart';
import '../../models/store_profile.dart';
import '../store_repository.dart';

/// Local, [SharedPreferences]-backed implementation of [StoreRepository].
class LocalStoreRepository implements StoreRepository {
  LocalStoreRepository(this._storage);

  final LocalStorageService _storage;

  static const _storageKey = 'store_profile';

  @override
  Future<StoreProfile> get() async {
    final raw = _storage.read(_storageKey);
    if (raw == null) {
      final defaultProfile = StoreProfile(
        name: AppConstants.defaultStoreName,
        description: 'Küçük ama şık bir moda butiği.',
        createdAt: DateTime.now(),
      );
      await save(defaultProfile);
      return defaultProfile;
    }
    return StoreProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(StoreProfile profile) {
    return _storage.write(_storageKey, jsonEncode(profile.toJson()));
  }
}
