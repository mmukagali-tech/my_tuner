import 'package:my_tuner/src/core/storage/storage_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class StorageProvider {
  // ignore: avoid_positional_boolean_parameters
  Future<bool> setBool(StorageKey key, bool value);
  Future<bool> setString(StorageKey key, String value);
  Future<bool> setInt(StorageKey key, int value);
  Future<bool> setDouble(StorageKey key, double value);
  Future<bool> setStringList(StorageKey key, List<String> value);
  T? get<T>(StorageKey key);
  Future<bool> delete(StorageKey key);
}

class SharedPreferencesStorageProvider implements StorageProvider {
  const SharedPreferencesStorageProvider(this._sharedPref);
  final SharedPreferences _sharedPref;

  @override
  Future<bool> setBool(StorageKey key, bool value) => _sharedPref.setBool(key.name, value);

  @override
  Future<bool> setString(StorageKey key, String value) => _sharedPref.setString(key.name, value);

  @override
  Future<bool> setInt(StorageKey key, int value) => _sharedPref.setInt(key.name, value);

  @override
  Future<bool> setDouble(StorageKey key, double value) => _sharedPref.setDouble(key.name, value);

  @override
  Future<bool> setStringList(StorageKey key, List<String> value) =>
      _sharedPref.setStringList(key.name, value);

  @override
  T? get<T>(StorageKey key) {
    try {
      return _sharedPref.get(key.name) as T?;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> delete(StorageKey key) => _sharedPref.remove(key.name);
}
