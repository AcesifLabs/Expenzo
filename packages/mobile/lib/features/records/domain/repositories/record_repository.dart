import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/record.dart';
export '../entities/record.dart';

import '../filters/record_filter.dart';
export '../filters/record_filter.dart';

/// Repository for managing expense/income records.
abstract class RecordRepository {
  /// Retrieves records with optional [dateRange], [categoryId], [limit], [offset].
  ///
  /// Returns [Right(List<Record>)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, List<Record>>> getRecords({
    DateTimeRange? dateRange,
    String? categoryId,
    int? limit,
    int? offset,
  });

  /// Retrieves records using a [filter] object, with remote fallback.
  ///
  /// Returns [Right(List<Record>)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, List<Record>>> getFilteredRecords(RecordFilter filter);

  /// Retrieves a record by its [id].
  ///
  /// Returns [Right(Record)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, Record>> getRecordById(String id);

  /// Adds a new [record].
  ///
  /// Returns [Right(Record)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, Record>> addRecord(Record record);

  /// Updates an existing [record].
  ///
  /// Returns [Right(Record)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, Record>> updateRecord(Record record);

  /// Deletes a record by [id].
  ///
  /// Returns [Right(unit)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, Unit>> deleteRecord(String id);

  /// Watches for changes to records, with optional [limit] and [offset].
  Stream<List<Record>> watchRecords({int? limit, int? offset});

  /// Checks if a record exists for the given [sourceId].
  ///
  /// Returns [Right(bool)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, bool>> recordExistsBySourceId(String sourceId);

  /// Gets the set of existing source IDs from the given [sourceIds] list.
  ///
  /// Returns [Right(Set<String>)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, Set<String>>> getExistingSourceIds(
    List<String> sourceIds,
  );

  /// Adds a batch of [records] in a single operation.
  ///
  /// Returns [Right(unit)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, Unit>> addRecordsBatch(List<Record> records);

  /// Retrieves records by [categoryId] within a [start] to [end] date range.
  ///
  /// Returns [Right(List<Record>)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, List<Record>>> getRecordsByCategoryAndDateRange(
    String categoryId,
    DateTime start,
    DateTime end,
  );

  /// Gets total spending for a [categoryId] within a [start] to [end] range.
  ///
  /// Returns [Right(double)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, double>> getCategorySpending(
    String categoryId,
    DateTime start,
    DateTime end,
  );

  /// Gets total spending across all categories within a date range.
  ///
  /// Returns [Right(double)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, double>> getTotalSpending(
    DateTime start,
    DateTime end,
  );

  /// Retrieves records by [start] and [end] date range only.
  ///
  /// Returns [Right(List<Record>)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, List<Record>>> getRecordsByDateRangeOnly(
    DateTime start,
    DateTime end,
  );
}
