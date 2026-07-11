import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
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

List<DateAmount> buildTrend(int days) {
  return List.generate(
    days,
    (i) => DateAmount(date: DateTime(2026, 1, i + 1), amount: 50),
  );
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

      expect(titles, contains('Recurring Expenses'));
      expect(titles, contains('Budget Status'));
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
        (item) => item.title == 'Highest Spending Day',
        orElse: () => throw StateError('Missing highest day insight'),
      );

      expect(highest.description, contains('Monday'));
      expect(highest.description, contains('200%'));
    });

    test('omits highest spending day insight when date is null', () {
      final result = getInsights(
        insights: buildSpendingInsights(),
        spendingTrend: const [],
        categoryBreakdown: const [],
      );

      final titles = unwrap(result).map((item) => item.title).toList();

      expect(titles, isNot(contains('Highest Spending Day')));
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
        (item) => item.title == 'Most Frequent Category',
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
        isNot(contains('Best Savings Week')),
      );
      expect(
        unwrap(withWeek).map((item) => item.title),
        contains('Best Savings Week'),
      );
    });
  });
}
