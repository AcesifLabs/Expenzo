import '../entities/recurring_frequency.dart';

const int kMaxCatchUpOccurrences = 365;

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

DateTime addMonths(DateTime date, int months, {int? dayOfMonth}) {
  final monthIndex = date.year * 12 + (date.month - 1) + months;
  final year = (monthIndex / 12).floor();
  final month = monthIndex - year * 12 + 1;
  final day = dayOfMonth ?? date.day;
  final lastDay = _lastDayOfMonth(year, month);
  final build = date.isUtc ? DateTime.utc : DateTime.new;

  return build(year, month, day > lastDay ? lastDay : day);
}

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

int _lastDayOfMonth(int year, int month) {
  return DateTime(year, month + 1, 0).day;
}
