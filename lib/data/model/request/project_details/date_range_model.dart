

class DateRangeModel {
  final DateTime from;
  final DateTime to;

  DateRangeModel({required this.from, required this.to});
}

class DateRangeHelper {
  static DateRangeModel lastWeek() {
    final now = DateTime.now();
    final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday this week
    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
    final endOfLastWeek = startOfThisWeek.subtract(const Duration(days: 1));
    return DateRangeModel(from: startOfLastWeek, to: endOfLastWeek);
  }

  static DateRangeModel thisWeek() {
    final now = DateTime.now();
    final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday this week
    final endOfThisWeek = startOfThisWeek.add(const Duration(days: 6));    // Sunday this week
    return DateRangeModel(from: startOfThisWeek, to: endOfThisWeek);
  }

  static DateRangeModel nextWeek() {
    final now = DateTime.now();
    final startOfNextWeek = now.add(Duration(days: 7 - now.weekday + 1)); // Next Monday
    final endOfNextWeek = startOfNextWeek.add(const Duration(days: 6));   // Next Sunday
    return DateRangeModel(from: startOfNextWeek, to: endOfNextWeek);
  }

  static DateRangeModel lastMonth() {
    final now = DateTime.now();
    final firstDayThisMonth = DateTime(now.year, now.month, 1);
    final lastDayLastMonth = firstDayThisMonth.subtract(const Duration(days: 1));
    final firstDayLastMonth = DateTime(lastDayLastMonth.year, lastDayLastMonth.month, 1);
    return DateRangeModel(from: firstDayLastMonth, to: lastDayLastMonth);
  }

  static DateRangeModel thisMonth() {
    final now = DateTime.now();
    final firstDayThisMonth = DateTime(now.year, now.month, 1);
    final firstDayNextMonth = DateTime(now.year, now.month + 1, 1);
    final lastDayThisMonth = firstDayNextMonth.subtract(const Duration(days: 1));
    return DateRangeModel(from: firstDayThisMonth, to: lastDayThisMonth);
  }

  static DateRangeModel nextMonth() {
    final now = DateTime.now();
    final firstDayNextMonth = DateTime(now.year, now.month + 1, 1);
    final firstDayMonthAfter = DateTime(now.year, now.month + 2, 1);
    final lastDayNextMonth = firstDayMonthAfter.subtract(const Duration(days: 1));
    return DateRangeModel(from: firstDayNextMonth, to: lastDayNextMonth);
  }
}
