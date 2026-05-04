
extension StringExtensions on String {
  bool containsIgnoreCase(String secondString) =>
      this.toLowerCase().contains(secondString.toLowerCase());
}

extension DoubleExtension on double {
  double toPrecision({int precision = 3}) =>
      double.parse(toStringAsFixed(precision));
}
