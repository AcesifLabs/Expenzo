import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/database/daos/category_dao.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../../domain/entities/date_amount.dart';
import '../../domain/entities/category_amount.dart';
import '../../domain/entities/spending_insights.dart';
import '../../domain/entities/granularity.dart';
import '../../domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final RecordDao recordDao;
  final CategoryDao categoryDao;

  ReportsRepositoryImpl({required this.recordDao, required this.categoryDao});

  /// Returns Left(Failure) on error.
  @override
  Future<Either<Failure, List<DateAmount>>> getSpendingTrend({
    required DateTime startDate,
    required DateTime endDate,
    required Granularity granularity,
  }) async {
    try {
      final results = await recordDao.getSpendingTrend(startDate, endDate);

      final Map<String, double> grouped = {};
      for (final row in results) {
        final date = row.read(recordDao.records.date) ?? DateTime.now();
        final amount = row.read(recordDao.records.amount.sum()) ?? 0.0;

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
    } catch (e, s) {
      print('Error: $e\n$s');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<Failure, List<CategoryAmount>>> getCategoryBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final results = await recordDao.getCategoryBreakdown(startDate, endDate);
      final allCategories = await categoryDao.getAllCategories();

      final categoryMap = <String, Category>{};
      for (final cat in allCategories) {
        categoryMap[cat.id.toString()] = cat;
      }

      final totals = _computeCategoryTotals(results);
      final totalAmount = totals.fold<double>(
        0,
        (sum, e) => sum + e.value.abs(),
      );

      final breakdown = _buildBreakdown(totals, categoryMap, totalAmount);
      breakdown.sort((a, b) => b.amount.compareTo(a.amount));

      return Right(breakdown);
    } catch (e, s) {
      print('Error: $e\n$s');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<Failure, SpendingInsights>> getSpendingInsights({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final records = await recordDao.getRecordsByDateRange(startDate, endDate);

      if (records.isEmpty) {
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
      for (final record in records) {
        totalSpent += record.amount.abs();
      }

      final dailyTotals = _computeDailyTotals(records);

      final highestResult = _findHighestDay(dailyTotals);

      final daysDiff = endDate.difference(startDate).inDays + 1;
      final avgDaily = daysDiff > 0 ? totalSpent / daysDiff : 0.0;

      return Right(
        SpendingInsights(
          highestDayDate: highestResult.date,
          highestDayAmount: highestResult.amount,
          avgDailySpending: avgDaily,
          totalTransactionCount: records.length,
          totalSpent: totalSpent,
        ),
      );
    } catch (e, s) {
      print('Error: $e\n$s');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  List<MapEntry<String, double>> _computeCategoryTotals(List<dynamic> results) {
    final List<MapEntry<String, double>> totals = [];
    for (final row in results) {
      final catId = row.read(recordDao.records.categoryId)?.toString() ?? '';
      final amount = row.read(recordDao.records.amount.sum()) ?? 0.0;
      totals.add(MapEntry(catId, amount.abs()));
    }

    return totals;
  }

  List<CategoryAmount> _buildBreakdown(
    List<MapEntry<String, double>> totals,
    Map<String, Category> categoryMap,
    double totalAmount,
  ) {
    return totals.map((entry) {
      final cat = categoryMap[entry.key];
      final percentage = totalAmount > 0
          ? (entry.value / totalAmount) * 100
          : 0.0;

      return CategoryAmount(
        categoryId: entry.key,
        categoryName: cat?.name ?? 'Uncategorized',
        emoji: cat?.emoji ?? '📌',
        amount: entry.value,
        percentage: percentage,
      );
    }).toList();
  }

  Map<String, double> _computeDailyTotals(List<Record> records) {
    final Map<String, double> dailyTotals = {};
    for (final record in records) {
      final amount = record.amount.abs();
      final key = '${record.date.year}-${record.date.month}-${record.date.day}';
      dailyTotals[key] = (dailyTotals[key] ?? 0.0) + amount;
    }

    return dailyTotals;
  }

  ({DateTime? date, double amount}) _findHighestDay(
    Map<String, double> dailyTotals,
  ) {
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
        int.parse(parts.first),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }

    return (date: highestDayDate, amount: highestAmount);
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
          int.parse(parts.first),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      case Granularity.monthly:
        return DateTime(int.parse(parts.first), int.parse(parts[1]), 1);
    }
  }
}
