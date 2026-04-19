import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/date_amount.dart';
import '../../domain/entities/category_amount.dart';
import '../../domain/entities/spending_insights.dart';
import '../../domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final AppDatabase appDatabase;

  ReportsRepositoryImpl({required this.appDatabase});

  @override
  Future<Either<Failure, List<DateAmount>>> getSpendingTrend({
    required DateTime startDate,
    required DateTime endDate,
    required Granularity granularity,
  }) async {
    try {
      final results = await _querySpendingTrend(
        startDate,
        endDate,
        granularity,
      );
      return Right(results);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryAmount>>> getCategoryBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final results = await _queryCategoryBreakdown(startDate, endDate);
      return Right(results);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SpendingInsights>> getSpendingInsights({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final results = await _querySpendingInsights(startDate, endDate);
      return Right(results);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  Future<List<DateAmount>> _querySpendingTrend(
    DateTime startDate,
    DateTime endDate,
    Granularity granularity,
  ) async {
    final db = appDatabase;

    // Get all expenses in date range ordered by date
    final query = db.select(db.expenses)
      ..where(
        (e) =>
            e.date.isBiggerOrEqualValue(startDate) &
            e.date.isSmallerOrEqualValue(endDate),
      )
      ..orderBy([(e) => OrderingTerm.asc(e.date)]);

    final expenses = await query.get();

    // Group by granularity
    final Map<String, double> grouped = {};

    for (final expense in expenses) {
      final key = _getDateKey(expense.date, granularity);
      grouped[key] = (grouped[key] ?? 0.0) + expense.amount.abs();
    }

    // Convert to list of DateAmount
    final List<DateAmount> result = [];
    for (final entry in grouped.entries) {
      result.add(
        DateAmount(
          date: _parseDateKey(entry.key, granularity),
          amount: entry.value,
        ),
      );
    }

    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  String _getDateKey(DateTime date, Granularity granularity) {
    switch (granularity) {
      case Granularity.daily:
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case Granularity.weekly:
        // Get start of week (Monday)
        final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
        return '${startOfWeek.year}-${startOfWeek.month.toString().padLeft(2, '0')}-${startOfWeek.day.toString().padLeft(2, '0')}';
      case Granularity.monthly:
        return '${date.year}-${date.month.toString().padLeft(2, '0')}';
    }
  }

  DateTime _parseDateKey(String key, Granularity granularity) {
    final parts = key.split('-');
    switch (granularity) {
      case Granularity.daily:
      case Granularity.weekly:
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      case Granularity.monthly:
        return DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
    }
  }

  Future<List<CategoryAmount>> _queryCategoryBreakdown(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = appDatabase;

    // Get expenses in date range
    final expenseQuery = db.select(db.expenses)
      ..where(
        (e) =>
            e.date.isBiggerOrEqualValue(startDate) &
            e.date.isSmallerOrEqualValue(endDate),
      );
    final expenses = await expenseQuery.get();

    // Get all categories
    final allCategories = await db.select(db.categories).get();

    // Build a map of category id -> category
    final categoryMap = <String, Category>{};
    for (final cat in allCategories) {
      categoryMap[cat.id.toString()] = cat;
    }

    // Group by category
    final Map<String, double> categoryTotals = {};
    double totalAmount = 0;

    for (final expense in expenses) {
      final catId = expense.categoryId?.toString() ?? '';
      categoryTotals[catId] =
          (categoryTotals[catId] ?? 0.0) + expense.amount.abs();
      totalAmount += expense.amount.abs();
    }

    // Convert to CategoryAmount with percentages
    final List<CategoryAmount> result = [];
    for (final entry in categoryTotals.entries) {
      final cat = categoryMap[entry.key];
      final percentage = totalAmount > 0
          ? (entry.value / totalAmount) * 100
          : 0.0;
      result.add(
        CategoryAmount(
          categoryId: entry.key,
          categoryName: cat?.name ?? 'Uncategorized',
          emoji: cat?.emoji ?? '📌',
          amount: entry.value,
          percentage: percentage.toDouble(),
        ),
      );
    }

    // Sort by amount descending
    result.sort((a, b) => b.amount.compareTo(a.amount));
    return result;
  }

  Future<SpendingInsights> _querySpendingInsights(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = appDatabase;

    final query = db.select(db.expenses)
      ..where(
        (e) =>
            e.date.isBiggerOrEqualValue(startDate) &
            e.date.isSmallerOrEqualValue(endDate),
      )
      ..orderBy([(e) => OrderingTerm.asc(e.date)]);

    final expenses = await query.get();

    if (expenses.isEmpty) {
      return const SpendingInsights(
        highestDayAmount: 0,
        avgDailySpending: 0,
        totalTransactionCount: 0,
        totalSpent: 0,
      );
    }

    // Calculate total
    double totalSpent = 0;
    for (final expense in expenses) {
      totalSpent += expense.amount.abs();
    }

    // Group by day to find highest
    final Map<String, double> dailyTotals = {};
    for (final expense in expenses) {
      final key =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';
      dailyTotals[key] = (dailyTotals[key] ?? 0.0) + expense.amount.abs();
    }

    String? highestDayKey;
    double highestAmount = 0;
    for (final entry in dailyTotals.entries) {
      if (entry.value > highestAmount) {
        highestAmount = entry.value;
        highestDayKey = entry.key;
      }
    }

    DateTime? highestDayDate;
    if (highestDayKey != null) {
      final parts = highestDayKey.split('-');
      highestDayDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }

    // Calculate average daily spending
    final daysDiff = endDate.difference(startDate).inDays + 1;
    final avgDaily = daysDiff > 0 ? totalSpent / daysDiff : 0.0;

    return SpendingInsights(
      highestDayDate: highestDayDate,
      highestDayAmount: highestAmount,
      avgDailySpending: avgDaily,
      totalTransactionCount: expenses.length,
      totalSpent: totalSpent,
    );
  }
}
