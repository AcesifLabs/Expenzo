class MonthEndHandler {
  static int getLastDayOfMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

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
    final effectiveDay = _resolveDayOfMonth(
      dayOfMonth,
      current.day,
      lastDayOfNextMonth,
    );

    return DateTime(nextYear, nextMonth, effectiveDay);
  }

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

  static int _resolveDayOfMonth(
    int? dayOfMonth,
    int currentDay,
    int lastDayOfNextMonth,
  ) {
    if (dayOfMonth == null) return currentDay;
    if (dayOfMonth > lastDayOfNextMonth) return lastDayOfNextMonth;

    return dayOfMonth;
  }
}

enum RecurringFrequencyType { daily, weekly, monthly, yearly }
