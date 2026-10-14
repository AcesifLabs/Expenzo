import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/core/utils/week_utils.dart';

import '../../support/factories/user_settings_factory.dart';

void main() {
  tearDown(() => WeekStart.current.value = FirstDayOfWeek.monday);

  group('WeekStart', () {
    test('startOfWeek without an argument follows WeekStart.current', () {
      WeekStart.current.value = FirstDayOfWeek.sunday;

      // 2026-10-14 is a Wednesday; its Sunday-start week began Oct 11.
      expect(startOfWeek(DateTime(2026, 10, 14, 10)), DateTime(2026, 10, 11));
    });

    test('a Saturday start on a Friday returns the previous Saturday', () {
      WeekStart.current.value = FirstDayOfWeek.saturday;

      expect(startOfWeek(DateTime(2026, 10, 16, 21)), DateTime(2026, 10, 10));
      expect(summaryWeekday(), DateTime.friday);
    });

    test('apply reports whether the day changed', () {
      expect(WeekStart.apply(FirstDayOfWeek.monday), isFalse);
      expect(WeekStart.apply(FirstDayOfWeek.saturday), isTrue);
      expect(WeekStart.current.value, FirstDayOfWeek.saturday);
      expect(WeekStart.apply(FirstDayOfWeek.saturday), isFalse);
    });

    test('a language switch moves an unset day; a stored day stays', () {
      final unset = makeUserSettings();
      final sunday = makeUserSettings(firstDayOfWeek: FirstDayOfWeek.sunday);

      // What ExpenzoApp does when the app language changes.
      expect(WeekStart.apply(unset.effectiveFirstDayOfWeek('en')), isFalse);
      expect(WeekStart.apply(unset.effectiveFirstDayOfWeek('bn')), isTrue);
      expect(WeekStart.current.value, FirstDayOfWeek.saturday);

      expect(WeekStart.apply(sunday.effectiveFirstDayOfWeek('bn')), isTrue);
      expect(WeekStart.apply(sunday.effectiveFirstDayOfWeek('en')), isFalse);
      expect(WeekStart.current.value, FirstDayOfWeek.sunday);
    });
  });

  group('startOfWeek', () {
    test('Monday start: every day Mon–Sun maps to Monday midnight', () {
      // 2026-10-12 is a Monday.
      for (var day = 12; day <= 18; day++) {
        expect(
          startOfWeek(DateTime(2026, 10, day, 15, 30)),
          DateTime(2026, 10, 12),
          reason: 'Oct $day',
        );
      }
    });

    test('crosses a month start', () {
      // 2026-11-01 is a Sunday; its week starts Monday Oct 26.
      expect(startOfWeek(DateTime(2026, 11, 1, 9)), DateTime(2026, 10, 26));
    });

    test('lands on midnight in a DST change week', () {
      // EU clocks change on 2026-03-29 (Sunday), US on 2026-03-08.
      final start = startOfWeek(DateTime(2026, 3, 29, 12));

      expect(start, DateTime(2026, 3, 23));
      expect(start.hour, 0);
    });

    test('Sunday and Saturday starts', () {
      final wednesday = DateTime(2026, 10, 14, 10);

      expect(
        startOfWeek(wednesday, firstWeekday: DateTime.sunday),
        DateTime(2026, 10, 11),
      );
      expect(
        startOfWeek(wednesday, firstWeekday: DateTime.saturday),
        DateTime(2026, 10, 10),
      );
      expect(
        startOfWeek(DateTime(2026, 10, 10), firstWeekday: DateTime.saturday),
        DateTime(2026, 10, 10),
      );
    });
  });

  test('summaryWeekday is the day before the first weekday', () {
    expect(summaryWeekday(), DateTime.sunday);
    expect(summaryWeekday(firstWeekday: DateTime.sunday), DateTime.saturday);
    expect(summaryWeekday(firstWeekday: DateTime.saturday), DateTime.friday);
  });

  group('nextWeeklySummaryAt', () {
    test('Sunday before 20:00 gives the same Sunday', () {
      expect(
        nextWeeklySummaryAt(DateTime(2026, 10, 18, 19, 59)),
        DateTime(2026, 10, 18, 20),
      );
    });

    test('Sunday at 20:00 gives next Sunday', () {
      expect(
        nextWeeklySummaryAt(DateTime(2026, 10, 18, 20)),
        DateTime(2026, 10, 25, 20),
      );
    });

    test('Sunday after 20:00 gives next Sunday', () {
      expect(
        nextWeeklySummaryAt(DateTime(2026, 10, 18, 21)),
        DateTime(2026, 10, 25, 20),
      );
    });

    test('midweek gives the coming Sunday', () {
      expect(
        nextWeeklySummaryAt(DateTime(2026, 10, 14, 8)),
        DateTime(2026, 10, 18, 20),
      );
    });
  });

  group('lastWeeklySummaryAt', () {
    test('on time gives the same Sunday 20:00', () {
      expect(
        lastWeeklySummaryAt(DateTime(2026, 10, 18, 20, 5)),
        DateTime(2026, 10, 18, 20),
      );
    });

    test('after midnight gives the Sunday just past', () {
      expect(
        lastWeeklySummaryAt(DateTime(2026, 10, 19, 1)),
        DateTime(2026, 10, 18, 20),
      );
    });

    test('before Sunday 20:00 gives the previous Sunday', () {
      expect(
        lastWeeklySummaryAt(DateTime(2026, 10, 18, 19)),
        DateTime(2026, 10, 11, 20),
      );
    });
  });

  group('nextDailyAt', () {
    test('before the hour gives today', () {
      expect(
        nextDailyAt(DateTime(2026, 10, 12, 8, 59), 9),
        DateTime(2026, 10, 12, 9),
      );
    });

    test('at the hour gives tomorrow', () {
      expect(
        nextDailyAt(DateTime(2026, 10, 12, 9), 9),
        DateTime(2026, 10, 13, 9),
      );
    });

    test('after the hour gives tomorrow', () {
      expect(
        nextDailyAt(DateTime(2026, 10, 12, 18), 9),
        DateTime(2026, 10, 13, 9),
      );
    });

    test('the last day of a month rolls into the next month', () {
      expect(
        nextDailyAt(DateTime(2026, 10, 31, 10), 9),
        DateTime(2026, 11, 1, 9),
      );
      expect(
        nextDailyAt(DateTime(2026, 12, 31, 10), 9),
        DateTime(2027, 1, 1, 9),
      );
    });
  });
}
