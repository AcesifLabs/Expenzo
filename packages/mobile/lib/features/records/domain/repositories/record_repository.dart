import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/record.dart';

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({required this.start, required this.end});
}

abstract class RecordRepository {
  Future<Either<CacheFailure, List<Record>>> getRecords({
    DateTimeRange? dateRange,
    int? categoryId,
    int? limit,
    int? offset,
  });
  Future<Either<CacheFailure, Record>> getRecordById(int id);
  Future<Either<CacheFailure, Record>> addRecord(Record record);
  Future<Either<CacheFailure, Record>> updateRecord(Record record);
  Future<Either<CacheFailure, Unit>> deleteRecord(int id);
  Stream<List<Record>> watchRecords({int? limit, int? offset});
  Future<Either<CacheFailure, bool>> recordExistsBySourceId(String sourceId);
  Future<Either<CacheFailure, Set<String>>> getExistingSourceIds(
    List<String> sourceIds,
  );
  Future<Either<CacheFailure, void>> addRecordsBatch(List<Record> records);
  Future<Either<CacheFailure, List<Record>>> getRecordsByCategoryAndDateRange(
    int categoryId,
    DateTime start,
    DateTime end,
  );
  Future<Either<CacheFailure, double>> getCategorySpending(
    int categoryId,
    DateTime start,
    DateTime end,
  );
  Future<Either<CacheFailure, double>> getTotalSpending(
    DateTime start,
    DateTime end,
  );
  Future<Either<CacheFailure, List<Record>>> getRecordsByDateRangeOnly(
    DateTime start,
    DateTime end,
  );
}
