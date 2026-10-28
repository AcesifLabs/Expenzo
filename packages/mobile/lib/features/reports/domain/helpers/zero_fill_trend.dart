import 'package:expense_tracker/core/utils/week_utils.dart';
import '../entities/date_amount.dart';
import '../entities/granularity.dart';

List<DateAmount> zeroFillTrend({
  required Map<DateTime, double> totals,
  required ({DateTime start, DateTime end}) range,
  required Granularity granularity,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final end = range.end;
  final last = periodStart(end.isAfter(today) ? today : end, granularity);
  final filled = <DateAmount>[];
  for (
    var cursor = periodStart(range.start, granularity);
    !cursor.isAfter(last);
    cursor = _nextPeriod(cursor, granularity)
  ) {
    filled.add(DateAmount(date: cursor, amount: totals[cursor] ?? 0));
  }

  return filled;
}

DateTime periodStart(
  DateTime date,
  Granularity granularity, {
  int? firstWeekday,
}) {
  switch (granularity) {
    case Granularity.daily:
      return DateTime(date.year, date.month, date.day);
    case Granularity.weekly:
      return startOfWeek(date, firstWeekday: firstWeekday);
    case Granularity.monthly:
      return DateTime(date.year, date.month);
  }
}

DateTime _nextPeriod(DateTime date, Granularity granularity) {
  switch (granularity) {
    case Granularity.daily:
      return DateTime(date.year, date.month, date.day + 1);
    case Granularity.weekly:
      return DateTime(date.year, date.month, date.day + 7);
    case Granularity.monthly:
      return DateTime(date.year, date.month + 1);
  }
}
