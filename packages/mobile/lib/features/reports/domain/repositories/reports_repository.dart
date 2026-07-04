import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/date_amount.dart';
import '../entities/category_amount.dart';
import '../entities/spending_insights.dart';
import '../entities/granularity.dart';

/// Repository for fetching spending reports and analytics.
abstract class ReportsRepository {
  /// Retrieves the spending trend for a date range at the given [granularity].
  ///
  /// Returns [Right(List<DateAmount>)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, List<DateAmount>>> getSpendingTrend({
    required DateTime startDate,
    required DateTime endDate,
    required Granularity granularity,
  });

  /// Retrieves spending breakdown by category for a date range.
  ///
  /// Returns [Right(List<CategoryAmount>)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, List<CategoryAmount>>> getCategoryBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Retrieves spending insights (comparisons, trends) for a date range.
  ///
  /// Returns [Right(SpendingInsights)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, SpendingInsights>> getSpendingInsights({
    required DateTime startDate,
    required DateTime endDate,
  });
}
