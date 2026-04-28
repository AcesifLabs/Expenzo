class MonthEndHandler {
  /// Get the last day of a given month
  static int getLastDayOfMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Calculate the next occurrence date for a monthly recurring transaction
  /// Handles the 31st edge case by moving to the last day of the month
  static DateTime getNextOccurrenceForMonthly({
    required DateTime current,
    int? dayOfMonth,
  }) {
    int nextMonth = current.month + 1;
    int nextYear = current.year;

    if (nextMonth > 12) {
      nextMonth = 1;
      nextYear++;
    }

    final lastDayOfNextMonth = getLastDayOfMonth(nextYear, nextMonth);

    final effectiveDay = dayOfMonth != null
        ? (dayOfMonth > lastDayOfNextMonth ? lastDayOfNextMonth : dayOfMonth)
        : current.day;

    return DateTime(nextYear, nextMonth, effectiveDay);
  }

  /// Calculate the next occurrence based on frequency
  static DateTime getNextOccurrence({
    required RecurringFrequencyType frequency,
    required DateTime current,
    int? dayOfMonth,
  }) {
    switch (frequency) {
      case RecurringFrequencyType.daily:
        return current.add(const Duration(days: 1));
      case RecurringFrequencyType.weekly:
        return current.add(const Duration(days: 7));
      case RecurringFrequencyType.monthly:
        return getNextOccurrenceForMonthly(
          current: current,
          dayOfMonth: dayOfMonth,
        );
      case RecurringFrequencyType.yearly:
        return DateTime(current.year + 1, current.month, current.day);
    }
  }
}

enum RecurringFrequencyType { daily, weekly, monthly, yearly }
