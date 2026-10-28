import 'package:expense_tracker/features/recurring/domain/entities/recurring_frequency.dart';
import 'package:expense_tracker/features/recurring/domain/helpers/next_occurrence.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';

import 'generators.dart';

int _lastDay(int year, int month) => DateTime(year, month + 1, 0).day;

int _calendarDays(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

void main() {
  property('50 steps move forward on the schedule without drifting', () {
    forAll(
      combine2(anyDateTime(), constantFrom(RecurringFrequency.values)),
      maxExamples: propertyTrials,
      (v) {
        final (start, frequency) = v;

        final dayOfMonth = start.day;
        var current = start;
        for (var i = 0; i < 50; i++) {
          final next = calculateNextOccurrence(
            current,
            frequency,
            dayOfMonth: dayOfMonth,
          );
          expect(next.isAfter(current), isTrue, reason: '$current → $next');
          switch (frequency) {
            case RecurringFrequency.daily || RecurringFrequency.weekly:
              final step = frequency == RecurringFrequency.daily ? 1 : 7;
              expect(_calendarDays(current, next), step);
              expect((next.hour, next.minute), (start.hour, start.minute));
            case RecurringFrequency.monthly || RecurringFrequency.yearly:
              final last = _lastDay(next.year, next.month);
              expect(next.day, dayOfMonth > last ? last : dayOfMonth);
              if (frequency == RecurringFrequency.yearly) {
                expect(next.month, start.month);
              }
          }
          current = next;
        }
      },
    );
  });
}
