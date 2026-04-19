import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../expenses/domain/entities/expense.dart';

enum Granularity { daily, weekly, monthly }

abstract class ReportsLocalDatasource {
  /// Get spending trend data for a date range with specified granularity
  Future<Either<Failure, List<DateAmount>>> getSpendingTrend({
    required DateTime startDate,
    required DateTime endDate,
    required Granularity granularity,
  });

  /// Get category breakdown for a date range
  Future<Either<Failure, List<CategoryAmount>>> getCategoryBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get spending insights for a date range
  Future<Either<Failure, SpendingInsights>> getSpendingInsights({
    required DateTime startDate,
    required DateTime endDate,
  });
}

class DateAmount {
  final DateTime date;
  final double amount;

  const DateAmount({required this.date, required this.amount});
}

class CategoryAmount {
  final String categoryId;
  final String categoryName;
  final String emoji;
  final double amount;
  final double percentage;

  const CategoryAmount({
    required this.categoryId,
    required this.categoryName,
    required this.emoji,
    required this.amount,
    required this.percentage,
  });
}

class SpendingInsights {
  final DateTime? highestDayDate;
  final double highestDayAmount;
  final double avgDailySpending;
  final int totalTransactionCount;
  final double totalSpent;

  const SpendingInsights({
    this.highestDayDate,
    required this.highestDayAmount,
    required this.avgDailySpending,
    required this.totalTransactionCount,
    required this.totalSpent,
  });
}
