import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/date_amount.dart';
import '../entities/category_amount.dart';
import '../entities/spending_insights.dart';

abstract class ReportsRepository {
  Future<Either<Failure, List<DateAmount>>> getSpendingTrend({
    required DateTime startDate,
    required DateTime endDate,
    required Granularity granularity,
  });

  Future<Either<Failure, List<CategoryAmount>>> getCategoryBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, SpendingInsights>> getSpendingInsights({
    required DateTime startDate,
    required DateTime endDate,
  });
}

enum Granularity { daily, weekly, monthly }
