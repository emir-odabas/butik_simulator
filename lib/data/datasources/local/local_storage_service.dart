import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] used by local repositories.
///
/// Kept deliberately generic (get/set a JSON string by key) so swapping
/// the storage backend later (e.g. to Hive or a database) only means
/// writing a new implementation of this interface, not touching every
/// repository.
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  String? read(String key) => _prefs.getString(key);

  Future<void> write(String key, String value) => _prefs.setString(key, value);

  Future<void> delete(String key) => _prefs.remove(key);

  bool contains(String key) => _prefs.containsKey(key);
}
