import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../../domain/entities/record.dart';
import '../../domain/repositories/record_repository.dart';
import '../datasources/record_local_datasource.dart';

class RecordRepositoryImpl implements RecordRepository {
  final RecordLocalDatasource localDatasource;

  RecordRepositoryImpl({required this.localDatasource});

  @override
  Future<Either<CacheFailure, List<Record>>> getRecords({
    DateTimeRange? dateRange,
    int? categoryId,
    int? limit,
    int? offset,
  }) async {
    try {
      final records = await localDatasource.getRecords(
        dateRange: dateRange,
        categoryId: categoryId,
        limit: limit,
        offset: offset,
      );
      return Right(records);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, Record>> getRecordById(int id) async {
    try {
      final record = await localDatasource.getRecordById(id);
      if (record == null) {
        return const Left(CacheFailure(message: 'Record not found'));
      }
      return Right(record);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, Record>> addRecord(Record record) async {
    try {
      final added = await localDatasource.addRecord(record);
      return Right(added);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, Record>> updateRecord(Record record) async {
    try {
      final updated = await localDatasource.updateRecord(record);
      return Right(updated);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> deleteRecord(int id) async {
    try {
      await localDatasource.deleteRecord(id);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Stream<List<Record>> watchRecords({int? limit, int? offset}) {
    return localDatasource.watchRecords(limit: limit, offset: offset);
  }

  @override
  Future<Either<CacheFailure, bool>> recordExistsBySourceId(
    String sourceId,
  ) async {
    try {
      final exists = await localDatasource.recordExistsBySourceId(sourceId);
      return Right(exists);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, Set<String>>> getExistingSourceIds(
    List<String> sourceIds,
  ) async {
    try {
      final existing = await localDatasource.getExistingSourceIds(sourceIds);
      return Right(existing);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, void>> addRecordsBatch(
    List<Record> records,
  ) async {
    try {
      await localDatasource.addRecordsBatch(records);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }
}
