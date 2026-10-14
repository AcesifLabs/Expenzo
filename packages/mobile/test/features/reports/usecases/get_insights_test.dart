import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/core/utils/week_utils.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/features/reports/domain/entities/category_amount.dart';
import 'package:expense_tracker/features/reports/domain/entities/date_amount.dart';
import 'package:expense_tracker/features/reports/domain/entities/insight_item.dart';
import 'package:expense_tracker/features/reports/domain/entities/spending_insights.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_insights.dart';

CategoryAmount buildCategoryAmount({
  String categoryId = 'cat-1',
  String categoryName = 'Food',
  String emoji = '🍔',
  double amount = 500,
  double percentage = 42,
}) {
  return CategoryAmount(
    categoryId: categoryId,
    categoryName: categoryName,
    emoji: emoji,
    amount: amount,
    percentage: percentage,
  );
}

SpendingInsights buildSpendingInsights({
  DateTime? highestDayDate,
  double highestDayAmount = 300,
  double avgDailySpending = 100,
  int totalTransactionCount = 20,
  double totalSpent = 2000,
}) {
  return SpendingInsights(
    highestDayDate: highestDayDate,
    highestDayAmount: highestDayAmount,
    avgDailySpending: avgDailySpending,
    totalTransactionCount: totalTransactionCount,
    totalSpent: totalSpent,
  );
}

/// Daily points from Monday 2026-01-05 (Monday is the default first day).
List<DateAmount> buildTrend(int days, {int startDay = 5}) {
  return List.generate(
    days,
    (i) => DateAmount(date: DateTime(2026, 1, startDay + i), amount: 50),
  );
}

InsightItem? savingsWeek(List<InsightItem> items) {
  for (final item in items) {
    if (item.kind == InsightKind.bestSavingsWeek) return item;
  }

  return null;
}

List<InsightItem> unwrap(Either<Object, List<InsightItem>> result) {
  return result.fold(
    (failure) => throw StateError('Expected Right but got Left: $failure'),
    (items) => items,
  );
}

void main() {
  const getInsights = GetInsights();

  group('GetInsights', () {
    test('always returns recurring and budget baseline insights', () {
      final result = getInsights(
        insights: buildSpendingInsights(),
        spendingTrend: const [],
        categoryBreakdown: const [],
      );

      final titles = unwrap(result).map((item) => item.title).toList();

      expect(titles, contains('Recurring expenses'));
      expect(titles, contains('Budget status'));
    });

    test('adds highest spending day insight when date is present', () {
      final result = getInsights(
        insights: buildSpendingInsights(
          highestDayDate: DateTime(2026, 1, 5),
          highestDayAmount: 300,
          avgDailySpending: 100,
        ),
        spendingTrend: const [],
        categoryBreakdown: const [],
      );

      final highest = unwrap(result).firstWhere(
        (item) => item.title == 'Highest spending day',
        orElse: () => throw StateError('Missing highest day insight'),
      );

      expect(highest.description, contains('Monday'));
      expect(highest.description, contains('200%'));
    });

    test('insight text follows the app language with Latin digits', () async {
      await initializeDateFormatting();
      DateFormat.useNativeDigitsByDefaultFor('bn', false);
      LocaleSettings.setLocaleSync(AppLocale.bn);
      Intl.defaultLocale = 'bn';
      addTearDown(() {
        LocaleSettings.setLocaleSync(AppLocale.en);
        Intl.defaultLocale = null;
      });

      final result = getInsights(
        insights: buildSpendingInsights(highestDayDate: DateTime(2026, 1, 5)),
        spendingTrend: const [],
        categoryBreakdown: const [],
      );
      final highest = unwrap(
        result,
      ).firstWhere((item) => item.kind == InsightKind.highestSpendingDay);

      expect(highest.title, t.reports.insights.highestDay.title);
      expect(highest.description, contains('সোমবার'));
      expect(highest.description, contains('200%'));
    });

    test('omits highest spending day insight when date is null', () {
      final result = getInsights(
        insights: buildSpendingInsights(),
        spendingTrend: const [],
        categoryBreakdown: const [],
      );

      final titles = unwrap(result).map((item) => item.title).toList();

      expect(titles, isNot(contains('Highest spending day')));
    });

    test('adds most frequent category insight from top category', () {
      final result = getInsights(
        insights: buildSpendingInsights(),
        spendingTrend: const [],
        categoryBreakdown: [
          buildCategoryAmount(categoryName: 'Groceries', percentage: 37),
        ],
      );

      final category = unwrap(result).firstWhere(
        (item) => item.title == 'Most frequent category',
        orElse: () => throw StateError('Missing category insight'),
      );

      expect(category.description, contains('Groceries'));
      expect(category.description, contains('37%'));
    });

    test('adds best savings week insight only with 7+ trend points', () {
      final withoutWeek = getInsights(
        insights: buildSpendingInsights(),
        spendingTrend: buildTrend(6),
        categoryBreakdown: const [],
      );
      final withWeek = getInsights(
        insights: buildSpendingInsights(),
        spendingTrend: buildTrend(7),
        categoryBreakdown: const [],
      );

      expect(
        unwrap(withoutWeek).map((item) => item.title),
        isNot(contains('Best savings week')),
      );
      expect(
        unwrap(withWeek).map((item) => item.title),
        contains('Best savings week'),
      );
    });

    test('assigns a semantic tone to each insight', () {
      final result = getInsights(
        insights: buildSpendingInsights(highestDayDate: DateTime(2026, 1, 5)),
        spendingTrend: buildTrend(7),
        categoryBreakdown: [buildCategoryAmount()],
      );

      final tones = {for (final item in unwrap(result)) item.title: item.tone};

      expect(tones, {
        'Highest spending day': InsightTone.warning,
        'Most frequent category': InsightTone.info,
        'Best savings week': InsightTone.positive,
        'Recurring expenses': InsightTone.investment,
        'Budget status': InsightTone.info,
      });
    });

    group('best savings week follows the first day of week', () {
      // Jan 2026: the 4th is a Sunday, the 10th a Saturday. Twenty days
      // from the 3rd, with the 11th-17th the cheapest Sunday week.
      final trend = [
        for (var day = 3; day <= 22; day++)
          DateAmount(
            date: DateTime(2026, 1, day),
            amount: day >= 11 && day <= 17 ? 1 : 50,
          ),
      ];

      InsightItem? weekFor(int firstWeekday, List<DateAmount> points) =>
          savingsWeek(
            unwrap(
              getInsights(
                insights: buildSpendingInsights(),
                spendingTrend: points,
                categoryBreakdown: const [],
                firstWeekday: firstWeekday,
              ),
            ),
          );

      test('Sunday start names a Sunday to Saturday week', () {
        final week = weekFor(DateTime.sunday, trend);

        expect(week?.weekStart, DateTime(2026, 1, 11));
        expect(week?.weekEnd, DateTime(2026, 1, 17));
      });

      test('Saturday start names a Saturday to Friday week', () {
        final week = weekFor(DateTime.saturday, trend);

        expect(week?.weekStart?.weekday, DateTime.saturday);
        expect(week?.weekEnd?.weekday, DateTime.friday);
        expect(week?.weekStart, DateTime(2026, 1, 10));
      });

      test('without firstWeekday, WeekStart decides', () {
        WeekStart.current.value = FirstDayOfWeek.saturday;
        addTearDown(() => WeekStart.current.value = FirstDayOfWeek.monday);

        final week = savingsWeek(
          unwrap(
            getInsights(
              insights: buildSpendingInsights(),
              spendingTrend: trend,
              categoryBreakdown: const [],
            ),
          ),
        );

        expect(week?.weekStart, DateTime(2026, 1, 10));
        expect(week?.weekEnd, DateTime(2026, 1, 16));
      });

      test('no full week from the first day gives no insight', () {
        // Seven days from a Monday hold no full Sunday-start week.
        expect(weekFor(DateTime.sunday, buildTrend(7)), isNull);
      });
    });
  });
}
