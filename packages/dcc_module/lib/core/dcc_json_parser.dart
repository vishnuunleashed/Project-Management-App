/// Safe JSON parsing utilities for the DCC module.
class DccJsonParser {
  static double? goodDouble(Map<String, dynamic> json, String key) {
    try {
      return json.containsKey(key) && json[key] != null
          ? double.tryParse(json[key].toString())
          : null;
    } catch (e) {
      return null;
    }
  }

  static int? goodInt(Map<String, dynamic> json, String key) {
    try {
      return json.containsKey(key) && json[key] != null
          ? int.tryParse(json[key].toString())
          : null;
    } catch (e) {
      return null;
    }
  }

  static String? goodString(Map<String, dynamic> json, String key) {
    try {
      return json.containsKey(key) && json[key] != null && json[key] != "null"
          ? json[key].toString()
          : null;
    } catch (e) {
      return null;
    }
  }

  static bool goodBoolean(Map<String, dynamic> json, String key) {
    try {
      final value = json[key];
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value > 0;
      if (value is String) {
        return value.toLowerCase() == "true" ||
            value.toLowerCase() == "y" ||
            value.toLowerCase() == "yes" ||
            value == "1";
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static List<T> goodList<T>(Map<String, dynamic> json, String key) {
    try {
      return json.containsKey(key) && json[key] is List
          ? List<T>.from(json[key])
          : [];
    } catch (e) {
      return [];
    }
  }

  static DateTime? goodDateTime(Map<String, dynamic> json, String key) {
    try {
      final value = json[key];
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    } catch (e) {
      return null;
    }
  }
}
