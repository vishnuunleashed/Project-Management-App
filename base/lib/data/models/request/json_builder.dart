
// Generic builder class for creating column-based data structures
class DataStructureBuilder {
  final List<Map<String, dynamic>> _columns = [];

  // Add a column with key-value pair
  DataStructureBuilder addColumn(String key, dynamic value) {
    _columns.add({
      "Key": key,
      "Value": value,
    });
    return this;
  }

  // Add multiple columns at once
  DataStructureBuilder addColumns(Map<String, dynamic> keyValuePairs) {
    keyValuePairs.forEach((key, value) {
      addColumn(key, value);
    });
    return this;
  }

  // Build the final data structure
  Map<String, dynamic> build() {
    return {
      "Columns": List<Map<String, dynamic>>.from(_columns)
    };
  }

  // Clear all columns
  DataStructureBuilder clear() {
    _columns.clear();
    return this;
  }

  // Remove a column by key
  DataStructureBuilder removeColumn(String key) {
    _columns.removeWhere((column) => column["Key"] == key);
    return this;
  }
}
