import 'dart:convert' show json;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DCCSecureStorage {
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

  static Future<int> setInt(String key, int value) async {
    await _storage.write(key: key, value: value.toString());
    return value;
  }

  // Bool
  static Future<bool> getBool(String key) async {
    final value = await _storage.read(key: key);
    return value == 'true';
  }

  static Future<bool> setBool(String key, bool value) async {
    await _storage.write(key: key, value: value.toString());
    return value;
  }

  // Map<String, dynamic>
  static Future<Map<String, dynamic>?> getMap(String key) async {
    try {
      final data = await _storage.read(key: key);
      return data == null || data.isEmpty ? null : json.decode(data);
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> setMap(
      String key, Map<String, dynamic> value) async {
    await _storage.write(key: key, value: json.encode(value));
    return value;
  }

  // List<dynamic>
  static Future<List<dynamic>?> getDynamicMap(String key) async {
    try {
      final data = await _storage.read(key: key);
      return data == null || data.isEmpty ? null : json.decode(data);
    } catch (e) {
      return null;
    }
  }

  static Future<List<dynamic>> setDynamicMap(
      String key, List<dynamic> value) async {
    await _storage.write(key: key, value: json.encode(value));
    return value;
  }

  // Clear all except system keys
  static Future<bool> clearAll() async {
    final allKeys = await _storage.readAll();
    for (final key in allKeys.keys) {
      if (key != "system") {
        print("logout___ removing: $key");
        await _storage.delete(key: key);
      }
    }
    return true;
  }
}


class FirebaseTokenStorage {
  static const _key = 'firebase_token_data';
  static const _storage = FlutterSecureStorage();

  /// Save Firebase token data securely (as a Map)
  static Future<void> saveTokenData(Map<String, dynamic> data) async {
    final jsonData = json.encode(data);
    await _storage.write(key: _key, value: jsonData);
  }

  /// Get the stored Firebase token data
  static Future<Map<String, dynamic>?> getTokenData() async {
    final jsonData = await _storage.read(key: _key);
    if (jsonData == null || jsonData.isEmpty) return null;

    try {
      return json.decode(jsonData) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Delete stored token data
  static Future<void> deleteTokenData() async {
    await _storage.delete(key: _key);
  }

  /// Check if token data exists
  static Future<bool> hasTokenData() async {
    final data = await _storage.read(key: _key);
    return data != null && data.isNotEmpty;
  }
}
