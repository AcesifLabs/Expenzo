import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';

class BudgetPeriodUtils {
  BudgetPeriodUtils._();

  static DateTimeRange calculateCurrentPeriod(
    DateTime startDate,
    BudgetPeriod period,
  ) {
    final now = DateTime.now();
    switch (period) {
      case BudgetPeriod.weekly:
        return _calculateWeeklyPeriod(startDate, now);
      case BudgetPeriod.monthly:
        return _calculateMonthlyPeriod(startDate, now);
      case BudgetPeriod.yearly:
        return _calculateYearlyPeriod(startDate, now);
    }
  }

  static DateTimeRange _calculateWeeklyPeriod(
    DateTime startDate,
    DateTime now,
  ) {
    final diff = now.difference(startDate).inDays;

    final offset = diff % 7;
    final periodStart = DateTime(now.year, now.month, now.day - offset);
    final periodEnd = DateTime(now.year, now.month, now.day - offset + 7);

    return DateTimeRange(start: periodStart, end: periodEnd);
  }

  static DateTimeRange _calculateMonthlyPeriod(
    DateTime startDate,
    DateTime now,
  ) {
    final startDay = startDate.day;
    final clampedStartDay = startDay.clamp(1, 28);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final effectiveStartDay = startDay > daysInMonth ? daysInMonth : startDay;

    DateTime periodStart;
    final thisMonthStart = DateTime(now.year, now.month, effectiveStartDay);

    if (now.isAtSameMomentAs(thisMonthStart) || now.isAfter(thisMonthStart)) {
      periodStart = thisMonthStart;
    } else {
      final prevMonth = now.month == 1 ? 12 : now.month - 1;
      final prevYear = now.month == 1 ? now.year - 1 : now.year;
      final daysInPrevMonth = DateTime(prevYear, prevMonth + 1, 0).day;
      final prevStartDay = startDay > daysInPrevMonth
          ? daysInPrevMonth
          : startDay;
      periodStart = DateTime(prevYear, prevMonth, prevStartDay);
    }

    DateTime periodEnd;
    if (periodStart.month == 12) {
      final daysInNextMonth = DateTime(periodStart.year + 1, 2, 0).day;
      final endDay = clampedStartDay > daysInNextMonth
          ? daysInNextMonth
          : clampedStartDay;
      periodEnd = DateTime(periodStart.year + 1, 1, endDay);
    } else {
      final daysInNextMonth = DateTime(
        periodStart.year,
        periodStart.month + 2,
        0,
      ).day;
      final endDay = clampedStartDay > daysInNextMonth
          ? daysInNextMonth
          : clampedStartDay;
      periodEnd = DateTime(periodStart.year, periodStart.month + 1, endDay);
    }

    return DateTimeRange(start: periodStart, end: periodEnd);
  }

  static DateTimeRange _calculateYearlyPeriod(
    DateTime startDate,
    DateTime now,
  ) {
    final startMonth = startDate.month;
    final startDay = startDate.day;
    final daysInMonth = DateTime(now.year, startMonth + 1, 0).day;
    final effectiveStartDay = startDay > daysInMonth ? daysInMonth : startDay;

    final thisYearStart = DateTime(now.year, startMonth, effectiveStartDay);
    final periodStartYear =
        now.isAtSameMomentAs(thisYearStart) || now.isAfter(thisYearStart)
        ? now.year
        : now.year - 1;

    final periodStart = DateTime(
      periodStartYear,
      startMonth,
      effectiveStartDay,
    );

    final endYear = periodStartYear + 1;
    final daysInEndMonth = DateTime(endYear, startMonth + 1, 0).day;
    final endDay = startDay > daysInEndMonth ? daysInEndMonth : startDay;
    final periodEnd = DateTime(endYear, startMonth, endDay);

    return DateTimeRange(start: periodStart, end: periodEnd);
  }
}
