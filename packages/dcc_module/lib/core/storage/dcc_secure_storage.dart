import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Internal secure storage wrapper for the DCC module.
/// Replicates the pattern of BaseSecureStorage from the main library.
class DccSecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Remove a specific key
  static Future<bool> remove(String key) async {
    await _storage.delete(key: key);
    return true;
  }

  // String
  static Future<String> getString(String key) async {
    return await _storage.read(key: key) ?? '';
  }

  static Future<String> setString(String key, String value) async {
    await _storage.write(key: key, value: value);
    return value;
  }

  // Int
  static Future<int> getInt(String key) async {
    final value = await _storage.read(key: key);
    return value != null ? int.tryParse(value) ?? 0 : 0;
  }

  static Future<int> getIntervalInSeconds(String key) async {
    final value = await _storage.read(key: key);
    return value != null ? int.tryParse(value) ?? 30 : 30;
  }

  static Future<int> setInt(String key, int value) async {
    await _storage.write(key: key, value: value.toString());
    return value;
  }

  // Clear all except system keys (if any)
  static Future<bool> clearAll() async {
    await _storage.deleteAll();
    return true;
  }
}
