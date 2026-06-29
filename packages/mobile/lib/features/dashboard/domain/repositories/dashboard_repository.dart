import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/dashboard_summary.dart';
import '../entities/date_range.dart';

/// Repository for fetching dashboard summary data.
abstract class DashboardRepository {
  /// Retrieves the dashboard summary for the given [dateRange].
  ///
  /// Returns [Right(DashboardSummary)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, DashboardSummary>> getDashboardSummary(
    DateRange dateRange,
  );
}
