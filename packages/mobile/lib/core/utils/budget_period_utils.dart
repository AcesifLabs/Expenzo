import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';

/// Budget periods: half-open [start, end) date ranges anchored on the
/// budget's start date. A monthly budget from the 31st runs to the next
/// month's 31st, or its last day when it is shorter (Feb 28, then Mar 31).
class BudgetPeriodUtils {
  BudgetPeriodUtils._();

  /// The period that holds today ([clock] in tests).
  static DateTimeRange calculateCurrentPeriod(
    DateTime startDate,
    BudgetPeriod period,
  ) => calculatePeriodAt(startDate, period, clock.now());

  /// The period that holds [at].
  static DateTimeRange calculatePeriodAt(
    DateTime startDate,
    BudgetPeriod period,
    DateTime at,
  ) {
    switch (period) {
      case BudgetPeriod.weekly:
        return _weeklyPeriod(startDate, at);
      case BudgetPeriod.monthly:
        return _monthlyPeriod(startDate, at);
      case BudgetPeriod.yearly:
        return _yearlyPeriod(startDate, at);
    }
  }

  /// The period just before [current], which ends where [current] starts.
  static DateTimeRange previousPeriod(
    DateTime startDate,
    BudgetPeriod period,
    DateTimeRange current,
  ) {
    final start = current.start;

    return calculatePeriodAt(
      startDate,
      period,
      DateTime(start.year, start.month, start.day - 1),
    );
  }

  /// Calendar days, not 24-hour blocks, so a clock change can't shift the
  /// week.
  static DateTimeRange _weeklyPeriod(DateTime startDate, DateTime at) {
    final days = DateTime.utc(at.year, at.month, at.day)
        .difference(
          DateTime.utc(startDate.year, startDate.month, startDate.day),
        )
        .inDays;
    final start = DateTime(at.year, at.month, at.day - days % 7);

    return DateTimeRange(
      start: start,
      end: DateTime(start.year, start.month, start.day + 7),
    );
  }

  static DateTimeRange _monthlyPeriod(DateTime startDate, DateTime at) {
    DateTime anchor(int year, int month) {
      // DateTime normalises month 0 and 13 into the next or previous year.
      final first = DateTime(year, month);

      return DateTime(
        first.year,
        first.month,
        _clampDay(startDate.day, first.year, first.month),
      );
    }

    final thisMonth = anchor(at.year, at.month);
    final start = at.isBefore(thisMonth)
        ? anchor(at.year, at.month - 1)
        : thisMonth;

    return DateTimeRange(
      start: start,
      end: anchor(start.year, start.month + 1),
    );
  }

  static DateTimeRange _yearlyPeriod(DateTime startDate, DateTime at) {
    DateTime anchor(int year) => DateTime(
      year,
      startDate.month,
      _clampDay(startDate.day, year, startDate.month),
    );

    final thisYear = anchor(at.year);
    final start = at.isBefore(thisYear) ? anchor(at.year - 1) : thisYear;

    return DateTimeRange(start: start, end: anchor(start.year + 1));
  }

  /// [day], or the last day of [year]-[month] when that month is shorter.
  static int _clampDay(int day, int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day;

    return day > lastDay ? lastDay : day;
  }
}
