import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/sync/sync_event.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import '../../domain/entities/record.dart';
import '../../domain/repositories/record_repository.dart';
import '../datasources/record_local_datasource.dart';

class RecordRepositoryImpl implements RecordRepository {
  final RecordLocalDatasource localDatasource;
  final SyncQueueDao? _syncQueueDao;

  RecordRepositoryImpl({
    required this.localDatasource,
    SyncQueueDao? syncQueueDao,
  }) : _syncQueueDao = syncQueueDao;

  void _enqueueSync(String action, String recordId, [Map<String, dynamic>? data]) {
    if (_syncQueueDao == null) return;
    _syncQueueDao!.enqueue(
      tableName: 'records',
      recordId: recordId,
      action: action,
      payload: data != null ? jsonEncode(data) : '',
    );
    SyncEventBus().trigger();
  }

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
      _enqueueSync('insert', added.id!.toString(), {
        'amount': added.amount, 'description': added.description,
        'date': added.date.toUtc().toIso8601String(),
        'categoryId': added.categoryId,
        'source': added.source.name, 'recordType': added.recordType.dbValue,
      });
      return Right(added);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, Record>> updateRecord(Record record) async {
    try {
      final updated = await localDatasource.updateRecord(record);
      _enqueueSync('update', updated.id!.toString(), {
        'amount': updated.amount, 'description': updated.description,
        'date': updated.date.toUtc().toIso8601String(),
        'categoryId': updated.categoryId,
        'source': updated.source.name, 'recordType': updated.recordType.dbValue,
      });
      return Right(updated);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> deleteRecord(int id) async {
    try {
      await localDatasource.deleteRecord(id);
      _enqueueSync('delete', id.toString());
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
  Future<Either<CacheFailure, List<Record>>> getRecordsByCategoryAndDateRange(
    int categoryId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final records = await localDatasource.getRecordsByCategoryAndDateRange(
        categoryId,
        start,
        end,
      );
      return Right(records);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, double>> getCategorySpending(
    int categoryId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final spending = await localDatasource.getCategorySpending(
        categoryId,
        start,
        end,
      );
      return Right(spending);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, double>> getTotalSpending(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final spending = await localDatasource.getTotalSpending(start, end);
      return Right(spending);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, List<Record>>> getRecordsByDateRangeOnly(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final records = await localDatasource.getRecordsByDateRangeOnly(
        start,
        end,
      );
      return Right(records);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, void>> addRecordsBatch(List<Record> records) async {
    try {
      await localDatasource.addRecordsBatch(records);
      for (final r in records) {
        if (r.id != null) {
          _enqueueSync('insert', r.id!.toString(), {
            'amount': r.amount, 'description': r.description,
            'date': r.date.toUtc().toIso8601String(),
            'categoryId': r.categoryId,
            'source': r.source.name, 'recordType': r.recordType.dbValue,
          });
        }
      }
      return const Right(null);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }
}
