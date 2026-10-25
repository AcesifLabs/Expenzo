import '../entities/recurring_frequency.dart';

/// Maximum number of catch-up occurrences to process in a single call.
/// Prevents unbounded loops if the app hasn't been opened for a very long time.
const int kMaxCatchUpOccurrences = 365;

/// Calculates the next occurrence date after [current] for the given [frequency].
///
/// Daily and weekly steps count calendar days and keep the time of day, so
/// a daylight-saving change doesn't shift it. Monthly and yearly steps land
/// at the start of [dayOfMonth] (or [current]'s day), clamped to the target
/// month's last day: a bill on the 31st is due Feb 28, then Mar 31 again as
/// long as [dayOfMonth] is 31. Every step keeps [current]'s UTC flag.
DateTime calculateNextOccurrence(
  DateTime current,
  RecurringFrequency frequency, {
  int? dayOfMonth,
}) {
  switch (frequency) {
    case RecurringFrequency.daily:
      return _withDate(current, current.year, current.month, current.day + 1);
    case RecurringFrequency.weekly:
      return _withDate(current, current.year, current.month, current.day + 7);
    case RecurringFrequency.monthly:
      return addMonths(current, 1, dayOfMonth: dayOfMonth);
    case RecurringFrequency.yearly:
      return addMonths(current, 12, dayOfMonth: dayOfMonth);
  }
}

/// The start of the day [months] months after [date] (negative goes back),
/// clamping the day to the target month's last day. Also used by the
/// onboarding goal timeline.
DateTime addMonths(DateTime date, int months, {int? dayOfMonth}) {
  final monthIndex = date.year * 12 + (date.month - 1) + months;
  final year = (monthIndex / 12).floor();
  final month = monthIndex - year * 12 + 1;
  final day = dayOfMonth ?? date.day;
  final lastDay = _lastDayOfMonth(year, month);
  final build = date.isUtc ? DateTime.utc : DateTime.new;

  return build(year, month, day > lastDay ? lastDay : day);
}

/// [year]-[month]-[day] at [source]'s time of day, UTC when [source] is.
/// Out-of-range days roll over the way [DateTime] does.
DateTime _withDate(DateTime source, int year, int month, int day) {
  final build = source.isUtc ? DateTime.utc : DateTime.new;

  return build(
    year,
    month,
    day,
    source.hour,
    source.minute,
    source.second,
    source.millisecond,
    source.microsecond,
  );
}

/// Returns the last day of the given month/year.
int _lastDayOfMonth(int year, int month) {
  return DateTime(year, month + 1, 0).day;
}
