import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/expense_dao.dart';
import 'package:expense_tracker/core/database/daos/category_dao.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../../domain/entities/date_amount.dart';
import '../../domain/entities/category_amount.dart';
import '../../domain/entities/spending_insights.dart';
import '../../domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ExpenseDao expenseDao;
  final CategoryDao categoryDao;

  ReportsRepositoryImpl({required this.expenseDao, required this.categoryDao});

  @override
  Future<Either<Failure, List<DateAmount>>> getSpendingTrend({
    required DateTime startDate,
    required DateTime endDate,
    required Granularity granularity,
  }) async {
    try {
      final results = await expenseDao.getSpendingTrend(startDate, endDate);

      final Map<String, double> grouped = {};
      for (final row in results) {
        final date = row.read(expenseDao.expenses.date)!;
        final amount = row.read(expenseDao.expenses.amount.sum()) ?? 0.0;

        final key = _getDateKey(date, granularity);
        grouped[key] = (grouped[key] ?? 0.0) + amount.abs();
      }

      final List<DateAmount> trend = [];
      for (final entry in grouped.entries) {
        trend.add(
          DateAmount(
            date: _parseDateKey(entry.key, granularity),
            amount: entry.value,
          ),
        );
      }

      trend.sort((a, b) => a.date.compareTo(b.date));
      return Right(trend);
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
      final results = await expenseDao.getCategoryBreakdown(startDate, endDate);
      final allCategories = await categoryDao.getAllCategories();

      final categoryMap = <String, Category>{};
      for (final cat in allCategories) {
        categoryMap[cat.id.toString()] = cat;
      }

      double totalAmount = 0;
      final List<MapEntry<String, double>> totals = [];
      for (final row in results) {
        final catId =
            row.read(expenseDao.expenses.categoryId)?.toString() ?? '';
        final amount = row.read(expenseDao.expenses.amount.sum()) ?? 0.0;
        totalAmount += amount.abs();
        totals.add(MapEntry(catId, amount.abs()));
      }

      final List<CategoryAmount> breakdown = [];
      for (final entry in totals) {
        final cat = categoryMap[entry.key];
        final percentage = totalAmount > 0
            ? (entry.value / totalAmount) * 100
            : 0.0;
        breakdown.add(
          CategoryAmount(
            categoryId: entry.key,
            categoryName: cat?.name ?? 'Uncategorized',
            emoji: cat?.emoji ?? '📌',
            amount: entry.value,
            percentage: percentage,
          ),
        );
      }

      breakdown.sort((a, b) => b.amount.compareTo(a.amount));
      return Right(breakdown);
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
      // For insights, we still need the full list to find highest day and average
      // but we could also do this with more specific SQL queries.
      // For now, let's keep it as is but using the DAO.
      final expenses = await expenseDao.getExpensesByDateRange(
        startDate,
        endDate,
      );

      if (expenses.isEmpty) {
        return const Right(
          SpendingInsights(
            highestDayAmount: 0,
            avgDailySpending: 0,
            totalTransactionCount: 0,
            totalSpent: 0,
          ),
        );
      }

      double totalSpent = 0;
      final Map<String, double> dailyTotals = {};
      for (final expense in expenses) {
        final amount = expense.amount.abs();
        totalSpent += amount;

        final key =
            '${expense.date.year}-${expense.date.month}-${expense.date.day}';
        dailyTotals[key] = (dailyTotals[key] ?? 0.0) + amount;
      }

      double highestAmount = 0;
      String? highestDayKey;
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

      final daysDiff = endDate.difference(startDate).inDays + 1;
      final avgDaily = daysDiff > 0 ? totalSpent / daysDiff : 0.0;

      return Right(
        SpendingInsights(
          highestDayDate: highestDayDate,
          highestDayAmount: highestAmount,
          avgDailySpending: avgDaily,
          totalTransactionCount: expenses.length,
          totalSpent: totalSpent,
        ),
      );
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  String _getDateKey(DateTime date, Granularity granularity) {
    switch (granularity) {
      case Granularity.daily:
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case Granularity.weekly:
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
}
