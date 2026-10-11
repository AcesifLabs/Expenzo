import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/record.dart';
export '../entities/record.dart';

import '../filters/record_filter.dart';
export '../filters/record_filter.dart';

abstract class RecordRepository {
  Future<Either<CacheFailure, List<Record>>> getRecords({
    DateTimeRange? dateRange,
    String? categoryId,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, List<Record>>> getFilteredRecords(RecordFilter filter);

  Future<Either<CacheFailure, Record>> getRecordById(String id);

  Future<Either<CacheFailure, Record>> addRecord(Record record);

  Future<Either<CacheFailure, Record>> updateRecord(Record record);

  Future<Either<CacheFailure, Unit>> deleteRecord(String id);

  Stream<List<Record>> watchRecords({int? limit, int? offset});

  /// Checks if a record exists for the given [sourceId].
  ///
  /// Returns [Right(bool)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, bool>> recordExistsBySourceId(String sourceId);

  Future<Either<CacheFailure, Set<String>>> getExistingSourceIds(
    List<String> sourceIds,
  );

  Future<Either<CacheFailure, Unit>> addRecordsBatch(List<Record> records);

  Future<Either<CacheFailure, List<Record>>> getRecordsByCategoryAndDateRange(
    String categoryId,
    DateTime start,
    DateTime end,
  );

  Future<Either<CacheFailure, double>> getCategorySpending(
    String categoryId,
    DateTime start,
    DateTime end,
  );

  Future<Either<CacheFailure, double>> getTotalSpending(
    DateTime start,
    DateTime end,
  );

  /// Expense spend per budget id, each over its own half-open [start, end)
  /// period, read in a single query. Every requested id is in the result.
  ///
  /// Returns [Right(Map)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, Map<String, double>>> getSpendingForBudgets(
    Map<String, ({DateTime start, DateTime end})> periods,
  );

  Future<Either<CacheFailure, List<Record>>> getRecordsByDateRangeOnly(
    DateTime start,
    DateTime end,
  );

  /// Returns the number of records that reference [categoryId].
  ///
  /// Returns [Right(int)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, int>> getRecordCountByCategory(String categoryId);

  /// Returns the number of records per category id. Categories with no
  /// records are absent from the map.
  ///
  /// Returns [Right(Map)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, Map<String, int>>> getCategoryRecordCounts();
}
