import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';

abstract final class WeekStart {
  static final current = ValueNotifier(FirstDayOfWeek.monday);

  static int get weekday => current.value.weekday;

  static bool apply(FirstDayOfWeek day) {
    final changed = current.value != day;
    current.value = day;

    return changed;
  }
}

DateTime startOfWeek(DateTime date, {int? firstWeekday}) {
  final offset = (date.weekday - (firstWeekday ?? WeekStart.weekday)) % 7;

  return DateTime(date.year, date.month, date.day - offset);
}

int summaryWeekday({required int firstWeekday}) {
  return firstWeekday == DateTime.monday ? DateTime.sunday : firstWeekday - 1;
}

DateTime nextWeeklySummaryAt(DateTime now, {required int firstWeekday}) {
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

DateTime lastWeeklySummaryAt(DateTime now, {required int firstWeekday}) {
  final next = nextWeeklySummaryAt(now, firstWeekday: firstWeekday);

  return DateTime(
    next.year,
    next.month,
    next.day - 7,
    AppConstants.weeklySummaryHour,
  );
}

DateTime nextDailyAt(DateTime now, int hour) {
  final today = DateTime(now.year, now.month, now.day, hour);

  return today.isAfter(now)
      ? today
      : DateTime(now.year, now.month, now.day + 1, hour);
}
