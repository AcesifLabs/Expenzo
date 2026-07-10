import '../entities/recurring_frequency.dart';

/// Maximum number of catch-up occurrences to process in a single call.
/// Prevents unbounded loops if the app hasn't been opened for a very long time.
const int kMaxCatchUpOccurrences = 365;

/// Calculates the next occurrence date after [current] for the given [frequency].
///
/// For monthly/yearly frequencies, clamps the day to the target month's last day
/// to handle month-end dates (e.g. Jan 31 → Feb 28).
/// If [dayOfMonth] is provided, uses it instead of [current]'s day.
DateTime calculateNextOccurrence(
  DateTime current,
  RecurringFrequency frequency, {
  int? dayOfMonth,
}) {
  switch (frequency) {
    case RecurringFrequency.daily:
      return current.add(const Duration(days: 1));
    case RecurringFrequency.weekly:
      return current.add(const Duration(days: 7));
    case RecurringFrequency.monthly:
      return _addMonths(current, 1, dayOfMonth: dayOfMonth);
    case RecurringFrequency.yearly:
      return _addYears(current, 1, dayOfMonth: dayOfMonth);
  }
}

/// Adds [months] months to [date], clamping the day to the target month's
/// last day if the original day exceeds the target month's days.
DateTime _addMonths(DateTime date, int months, {int? dayOfMonth}) {
  final targetMonth = date.month + months;
  final targetYear = date.year + ((targetMonth - 1) ~/ 12);
  final normalizedMonth = ((targetMonth - 1) % 12) + 1;
  final day = dayOfMonth ?? date.day;
  final lastDayOfMonth = _lastDayOfMonth(targetYear, normalizedMonth);
  final clampedDay = day > lastDayOfMonth ? lastDayOfMonth : day;

  return DateTime(targetYear, normalizedMonth, clampedDay);
}

/// Adds [years] years to [date], clamping for Feb 29 → Feb 28 on non-leap years.
DateTime _addYears(DateTime date, int years, {int? dayOfMonth}) {
  final targetYear = date.year + years;
  final day = dayOfMonth ?? date.day;
  final lastDayOfMonth = _lastDayOfMonth(targetYear, date.month);
  final clampedDay = day > lastDayOfMonth ? lastDayOfMonth : day;

  return DateTime(targetYear, date.month, clampedDay);
}

/// Returns the last day of the given month/year.
int _lastDayOfMonth(int year, int month) {
  // Day 0 of next month = last day of current month
  return DateTime(year, month + 1, 0).day;
}
