import 'package:clock/clock.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/utils/budget_period_utils.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every day of [year], at noon.
Iterable<DateTime> _daysOf(int year) sync* {
  for (
    var d = DateTime(year, 1, 1, 12);
    d.year == year;
    d = DateTime(d.year, d.month, d.day + 1, 12)
  ) {
    yield d;
  }
}

void main() {
  for (final period in BudgetPeriod.values) {
    for (final year in [2026, 2028]) {
      test(
        '${period.name} periods hold today for every start day in $year',
        () {
          for (var startDay = 1; startDay <= 31; startDay++) {
            final start = DateTime(2025, 1, startDay);
            for (final today in _daysOf(year)) {
              final range = BudgetPeriodUtils.calculatePeriodAt(
                start,
                period,
                today,
              );

              expect(
                !range.start.isAfter(today) && today.isBefore(range.end),
                isTrue,
                reason: 'start day $startDay, today $today: $range',
              );
            }
          }
        },
      );
    }

    test('${period.name} periods tile with no gap or overlap', () {
      final start = DateTime(2025, 1, 31);
      var range = BudgetPeriodUtils.calculatePeriodAt(
        start,
        period,
        DateTime(2026, 1, 1),
      );
      for (var i = 0; i < 40; i++) {
        final next = BudgetPeriodUtils.calculatePeriodAt(
          start,
          period,
          range.end,
        );
        expect(next.start, range.end, reason: 'after $range');
        range = next;
      }
    });
  }

  test('a monthly budget from the 31st runs to the next month\'s anchor', () {
    final range = BudgetPeriodUtils.calculatePeriodAt(
      DateTime(2025, 1, 31),
      BudgetPeriod.monthly,
      DateTime(2026, 3, 30),
    );

    expect(range.start, DateTime(2026, 2, 28));
    expect(range.end, DateTime(2026, 3, 31));
  });

  test('a weekly period is 7 calendar days across a clock change', () {
    final range = BudgetPeriodUtils.calculatePeriodAt(
      DateTime(2026, 3, 2),
      BudgetPeriod.weekly,
      DateTime(2026, 3, 10, 0, 30),
    );

    expect(range.start, DateTime(2026, 3, 9));
    expect(range.end, DateTime(2026, 3, 16));
  });

  test('previousPeriod is the period that ends where the current starts', () {
    final current = BudgetPeriodUtils.calculatePeriodAt(
      DateTime(2025, 1, 31),
      BudgetPeriod.monthly,
      DateTime(2026, 3, 30),
    );
    final previous = BudgetPeriodUtils.previousPeriod(
      DateTime(2025, 1, 31),
      BudgetPeriod.monthly,
      current,
    );

    expect(previous.end, current.start);
    expect(previous.start, DateTime(2026, 1, 31));
  });

  test('calculateCurrentPeriod reads the injected clock', () {
    final range = withClock(
      Clock.fixed(DateTime(2026, 6, 15)),
      () => BudgetPeriodUtils.calculateCurrentPeriod(
        DateTime(2026, 1, 1),
        BudgetPeriod.monthly,
      ),
    );

    expect(range.start, DateTime(2026, 6, 1));
  });
}
