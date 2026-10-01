import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage_service.dart';

/// The [SharedPreferences] instance, provided synchronously via an
/// override set up in `main()` (after awaiting `SharedPreferences
/// .getInstance()`), so the rest of the app can depend on it as a plain
/// [Provider] instead of every screen dealing with a [FutureProvider].
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() before use.',
  );
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService(ref.watch(sharedPreferencesProvider));
});
