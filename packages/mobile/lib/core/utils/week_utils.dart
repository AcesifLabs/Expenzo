import 'package:expense_tracker/core/constants/app_constants.dart';

/// Until SAAP-67 adds the setting.
const int defaultFirstWeekday = DateTime.monday;

/// Midnight of the most recent [firstWeekday] on or before [date].
DateTime startOfWeek(DateTime date, {int firstWeekday = defaultFirstWeekday}) {
  final offset = (date.weekday - firstWeekday) % 7;

  // Calendar arithmetic, not Duration, so a DST change keeps midnight.
  return DateTime(date.year, date.month, date.day - offset);
}

/// The day before [firstWeekday]: the weekly summary goes out that evening.
int summaryWeekday({int firstWeekday = defaultFirstWeekday}) =>
    firstWeekday == DateTime.monday ? DateTime.sunday : firstWeekday - 1;

/// The next summary time strictly after [now].
DateTime nextWeeklySummaryAt(
  DateTime now, {
  int firstWeekday = defaultFirstWeekday,
}) {
  final weekday = summaryWeekday(firstWeekday: firstWeekday);
  final daysAhead = (weekday - now.weekday) % 7;
  final candidate = DateTime(
    now.year,
    now.month,
    now.day + daysAhead,
    AppConstants.weeklySummaryHour,
  );

  return candidate.isAfter(now)
      ? candidate
      : DateTime(
          candidate.year,
          candidate.month,
          candidate.day + 7,
          AppConstants.weeklySummaryHour,
        );
}

/// The latest summary time at or before [now]. A summary that runs late
/// (after midnight) still reports the week it was due for.
DateTime lastWeeklySummaryAt(
  DateTime now, {
  int firstWeekday = defaultFirstWeekday,
}) {
  final next = nextWeeklySummaryAt(now, firstWeekday: firstWeekday);

  return DateTime(
    next.year,
    next.month,
    next.day - 7,
    AppConstants.weeklySummaryHour,
  );
}

/// Today at [hour]:00 when that is still ahead of [now], else tomorrow.
DateTime nextDailyAt(DateTime now, int hour) {
  final today = DateTime(now.year, now.month, now.day, hour);

  return today.isAfter(now)
      ? today
      : DateTime(now.year, now.month, now.day + 1, hour);
}
