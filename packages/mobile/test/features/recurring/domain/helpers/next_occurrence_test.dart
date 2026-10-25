import 'package:expense_tracker/features/recurring/domain/entities/recurring_frequency.dart';
import 'package:expense_tracker/features/recurring/domain/helpers/next_occurrence.dart';
import 'package:flutter_test/flutter_test.dart';

/// [count] steps of [frequency] from [start], anchored to [dayOfMonth].
List<DateTime> _steps(
  DateTime start,
  RecurringFrequency frequency,
  int count, {
  int? dayOfMonth,
}) {
  final dates = <DateTime>[];
  var current = start;
  for (var i = 0; i < count; i++) {
    current = calculateNextOccurrence(
      current,
      frequency,
      dayOfMonth: dayOfMonth,
    );
    dates.add(current);
  }

  return dates;
}

void main() {
  group('monthly', () {
    test('a bill on the 31st clamps in short months and comes back', () {
      final dates = _steps(
        DateTime(2026, 1, 31),
        RecurringFrequency.monthly,
        3,
        dayOfMonth: 31,
      );

      expect(dates, [
        DateTime(2026, 2, 28),
        DateTime(2026, 3, 31),
        DateTime(2026, 4, 30),
      ]);
    });

    test('February of a leap year takes the 29th', () {
      expect(
        calculateNextOccurrence(
          DateTime(2028, 1, 31),
          RecurringFrequency.monthly,
          dayOfMonth: 31,
        ),
        DateTime(2028, 2, 29),
      );
    });

    for (final day in [29, 30, 31]) {
      test('24 steps from day $day never drift', () {
        final dates = _steps(
          DateTime(2026, 1, day),
          RecurringFrequency.monthly,
          24,
          dayOfMonth: day,
        );

        for (final date in dates) {
          final lastDay = DateTime(date.year, date.month + 1, 0).day;
          expect(date.day, day < lastDay ? day : lastDay, reason: '$date');
        }
      });
    }

    test('December rolls into January of the next year', () {
      expect(
        calculateNextOccurrence(
          DateTime(2026, 12, 15),
          RecurringFrequency.monthly,
        ),
        DateTime(2027, 1, 15),
      );
    });
  });

  group('yearly', () {
    test('Feb 29 falls to Feb 28 and returns in the next leap year', () {
      final dates = _steps(
        DateTime(2028, 2, 29),
        RecurringFrequency.yearly,
        4,
        dayOfMonth: 29,
      );

      expect(dates, [
        DateTime(2029, 2, 28),
        DateTime(2030, 2, 28),
        DateTime(2031, 2, 28),
        DateTime(2032, 2, 29),
      ]);
    });
  });

  group('addMonths', () {
    test('negative months go back across the year', () {
      expect(addMonths(DateTime(2026, 1, 15), -1), DateTime(2025, 12, 15));
      expect(addMonths(DateTime(2026, 1, 15), -13), DateTime(2024, 12, 15));
      expect(addMonths(DateTime(2026, 3, 31), -1), DateTime(2026, 2, 28));
    });

    test('large positive steps keep the year right', () {
      expect(addMonths(DateTime(2026, 11, 1), 14), DateTime(2028, 1, 1));
    });
  });

  group('time of day and time zone', () {
    for (final frequency in [
      RecurringFrequency.daily,
      RecurringFrequency.weekly,
    ]) {
      test('${frequency.name} keeps the time of day', () {
        final next = calculateNextOccurrence(
          DateTime(2026, 3, 7, 9, 30),
          frequency,
        );

        expect((next.hour, next.minute), (9, 30));
      });
    }

    for (final frequency in [
      RecurringFrequency.monthly,
      RecurringFrequency.yearly,
    ]) {
      test('${frequency.name} is due from the start of the day', () {
        final next = calculateNextOccurrence(
          DateTime(2026, 3, 7, 9, 30),
          frequency,
        );

        expect((next.hour, next.minute), (0, 0));
      });
    }

    for (final frequency in RecurringFrequency.values) {
      test('${frequency.name} keeps a UTC date in UTC', () {
        final next = calculateNextOccurrence(
          DateTime.utc(2026, 3, 7, 9, 30),
          frequency,
        );

        expect(next.isUtc, isTrue);
      });
    }

    test('daily steps are calendar days, so 52 weeks of steps land on the '
        'same weekday and hour', () {
      var current = DateTime(2026, 1, 5, 8);
      for (var i = 0; i < 364; i++) {
        current = calculateNextOccurrence(current, RecurringFrequency.daily);
      }

      expect(current, DateTime(2027, 1, 4, 8));
    });
  });
}
