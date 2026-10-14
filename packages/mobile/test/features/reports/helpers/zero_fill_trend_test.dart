import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/core/utils/week_utils.dart';
import 'package:expense_tracker/features/reports/domain/entities/granularity.dart';
import 'package:expense_tracker/features/reports/domain/helpers/zero_fill_trend.dart';

void main() {
  test('one spending day becomes one bar among zero days', () {
    final trend = zeroFillTrend(
      totals: {DateTime(2026, 10, 3): 122},
      range: (start: DateTime(2026, 10, 1), end: DateTime(2026, 10, 5, 23, 59)),
      granularity: Granularity.daily,
      now: DateTime(2026, 10, 20),
    );

    expect(trend.map((d) => d.date.day), [1, 2, 3, 4, 5]);
    expect(trend.map((d) => d.amount), [0, 0, 122, 0, 0]);
  });

  test('stops at today instead of drawing empty future days', () {
    final trend = zeroFillTrend(
      totals: const {},
      range: (
        start: DateTime(2026, 10, 1),
        end: DateTime(2026, 10, 31, 23, 59),
      ),
      granularity: Granularity.daily,
      now: DateTime(2026, 10, 11, 15),
    );

    expect(trend, hasLength(11));
    expect(trend.last.date, DateTime(2026, 10, 11));
  });

  test('monthly and weekly periods step by calendar', () {
    final months = zeroFillTrend(
      totals: {DateTime(2026, 2): 5},
      range: (start: DateTime(2026, 1, 15), end: DateTime(2026, 3, 2)),
      granularity: Granularity.monthly,
      now: DateTime(2026, 12, 1),
    );
    expect(months.map((d) => d.date.month), [1, 2, 3]);
    expect(months[1].amount, 5);

    // 2026-10-07 is a Wednesday; weeks start on Monday 2026-10-05.
    final weeks = zeroFillTrend(
      totals: const {},
      range: (start: DateTime(2026, 10, 7), end: DateTime(2026, 10, 20)),
      granularity: Granularity.weekly,
      now: DateTime(2026, 12, 1),
    );
    expect(weeks.map((d) => d.date.day), [5, 12, 19]);
  });

  group('weekly buckets start on the first day of week', () {
    // 2026-10-07 is a Wednesday.
    tearDown(() => WeekStart.current.value = FirstDayOfWeek.monday);

    List<int> weekStarts(FirstDayOfWeek day) {
      WeekStart.current.value = day;

      return zeroFillTrend(
        totals: const {},
        range: (start: DateTime(2026, 10, 7), end: DateTime(2026, 10, 20)),
        granularity: Granularity.weekly,
        now: DateTime(2026, 12, 1),
      ).map((d) => d.date.day).toList();
    }

    test('Sunday', () {
      expect(weekStarts(FirstDayOfWeek.sunday), [4, 11, 18]);
    });

    test('Saturday', () {
      expect(weekStarts(FirstDayOfWeek.saturday), [3, 10, 17]);
    });

    test('periodStart takes an explicit first day', () {
      expect(
        periodStart(
          DateTime(2026, 10, 7),
          Granularity.weekly,
          firstWeekday: DateTime.saturday,
        ),
        DateTime(2026, 10, 3),
      );
    });
  });
}
