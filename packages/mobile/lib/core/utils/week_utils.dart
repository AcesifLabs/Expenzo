import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';

/// The user's effective first day of week. `ExpenzoApp` and the background
/// isolate set it from Settings; the helpers below read it when no
/// `firstWeekday` is given.
abstract final class WeekStart {
  static final current = ValueNotifier(FirstDayOfWeek.monday);

  static int get weekday => current.value.weekday;

  /// Sets [current] to [day]. Returns true when that changed it, so a
  /// caller can re-arm work that depends on the week start.
  static bool apply(FirstDayOfWeek day) {
    final changed = current.value != day;
    current.value = day;

    return changed;
  }
}

/// Midnight of the most recent [firstWeekday] (default [WeekStart]) on or
/// before [date].
DateTime startOfWeek(DateTime date, {int? firstWeekday}) {
  final offset = (date.weekday - (firstWeekday ?? WeekStart.weekday)) % 7;

  // Calendar arithmetic, not Duration, so a DST change keeps midnight.
  return DateTime(date.year, date.month, date.day - offset);
}

/// The day before [firstWeekday]: the weekly summary goes out that evening.
int summaryWeekday({int? firstWeekday}) {
  final first = firstWeekday ?? WeekStart.weekday;

  return first == DateTime.monday ? DateTime.sunday : first - 1;
}

/// The next summary time strictly after [now].
DateTime nextWeeklySummaryAt(DateTime now, {int? firstWeekday}) {
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
DateTime lastWeeklySummaryAt(DateTime now, {int? firstWeekday}) {
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
