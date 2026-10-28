import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/sync/sync_event.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import '../../domain/repositories/record_repository.dart';
import '../datasources/record_local_datasource.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/error/failure_message.dart';

class RecordRepositoryImpl implements RecordRepository {
  final RecordLocalDatasource localDatasource;
  final SyncQueueDao? _syncQueueDao;

  RecordRepositoryImpl({
    required this.localDatasource,
    SyncQueueDao? syncQueueDao,
  }) : _syncQueueDao = syncQueueDao;

  @override
  Future<Either<CacheFailure, List<Record>>> getRecords({
    DateTimeRange? dateRange,
    String? categoryId,
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
    } catch (e, s) {
      appLogger.error('RecordRepositoryImpl.getRecords failed', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<Record>> watchFilteredRecords(RecordFilter filter) =>
      localDatasource.watchFilteredRecords(filter);

  @override
  Future<Either<CacheFailure, List<Record>>> getFilteredRecords(
    RecordFilter filter,
  ) async {
    try {
      return Right(await localDatasource.getFilteredRecords(filter));
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('RecordRepositoryImpl.getFilteredRecords failed', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, Record>> getRecordById(String id) async {
    try {
      final record = await localDatasource.getRecordById(id);
      if (record == null) {
        return const Left(
          CacheFailure(
            message: 'Record not found',
            errorCode: FailureCodes.notFound,
          ),
        );
      }

      return Right(record);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('RecordRepositoryImpl.getRecordById failed', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, Record>> addRecord(Record record) async {
    try {
      final added = await localDatasource.addRecord(record);
      final addedId = added.id;
      if (addedId != null) {
        await _enqueueSync('insert', addedId, {
          'amount': added.amount,
          'description': added.description,
          'date': added.date.toUtc().toIso8601String(),
          'categoryId': added.categoryId,
          'budgetId': added.budgetId,
          'source': added.source.name,
          'recordType': added.recordType.dbValue,
        });
      }

      return Right(added);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('RecordRepositoryImpl.addRecord failed', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, Record>> updateRecord(Record record) async {
    try {
      final updated = await localDatasource.updateRecord(record);
      final updatedId = updated.id;
      if (updatedId != null) {
        await _enqueueSync('update', updatedId, {
          'amount': updated.amount,
          'description': updated.description,
          'date': updated.date.toUtc().toIso8601String(),
          'categoryId': updated.categoryId,
          'budgetId': updated.budgetId,
          'source': updated.source.name,
          'recordType': updated.recordType.dbValue,
        });
      }

      return Right(updated);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('RecordRepositoryImpl.updateRecord failed', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> deleteRecord(String id) async {
    try {
      await localDatasource.deleteRecord(id);
      await _enqueueSync('delete', id);

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('RecordRepositoryImpl.deleteRecord failed', e, s);

      return Left(CacheFailure(message: e.toString()));
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
    } catch (e, s) {
      appLogger.error(
        'RecordRepositoryImpl.recordExistsBySourceId failed',
        e,
        s,
      );

      return Left(CacheFailure(message: e.toString()));
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
    } catch (e, s) {
      appLogger.error('RecordRepositoryImpl.getExistingSourceIds failed', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, Map<String, List<double>>>> getAmountsBySourceIds(
    List<String> sourceIds,
  ) async {
    try {
      return Right(await localDatasource.getAmountsBySourceIds(sourceIds));
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error(
        'RecordRepositoryImpl.getAmountsBySourceIds failed',
        e,
        s,
      );

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, List<Record>>> getRecordsByCategoryAndDateRange(
    String categoryId,
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
    } catch (e, s) {
      appLogger.error(
        'RecordRepositoryImpl.getRecordsByCategoryAndDateRange failed',
        e,
        s,
      );

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, double>> getCategorySpending(
    String categoryId,
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
    } catch (e, s) {
      appLogger.error('RecordRepositoryImpl.getCategorySpending failed', e, s);

      return Left(CacheFailure(message: e.toString()));
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
    } catch (e, s) {
      appLogger.error('RecordRepositoryImpl.getTotalSpending failed', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, Map<String, double>>> getSpendingForBudgets(
    Map<String, ({DateTime start, DateTime end})> periods,
  ) async {
    try {
      final spending = await localDatasource.getSpendingForBudgets(periods);

      return Right(spending);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error(
        'RecordRepositoryImpl.getSpendingForBudgets failed',
        e,
        s,
      );

      return Left(CacheFailure(message: e.toString()));
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
    } catch (e, s) {
      appLogger.error(
        'RecordRepositoryImpl.getRecordsByDateRangeOnly failed',
        e,
        s,
      );

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> addRecordsBatch(
    List<Record> records,
  ) async {
    try {
      final withIds = [
        for (final r in records)
          r.id == null ? r.copyWith(id: const Uuid().v4()) : r,
      ];
      final inserted = await localDatasource.addRecordsBatch(withIds);
      final syncQueueDao = _syncQueueDao;
      if (syncQueueDao == null || inserted.isEmpty) return const Right(unit);
      await syncQueueDao.enqueueAll([
        for (final r in withIds)
          if (r.id case final recordId? when inserted.contains(recordId))
            (
              tableName: 'records',
              recordId: recordId,
              action: 'insert',
              payload: jsonEncode({
                'amount': r.amount,
                'description': r.description,
                'date': r.date.toUtc().toIso8601String(),
                'categoryId': r.categoryId,
                'budgetId': r.budgetId,
                'source': r.source.name,
                'recordType': r.recordType.dbValue,
              }),
            ),
      ]);
      SyncEventBus().trigger();

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('RecordRepositoryImpl.addRecordsBatch failed', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, int>> getRecordCountByCategory(
    String categoryId,
  ) async {
    try {
      final count = await localDatasource.getRecordCountByCategory(categoryId);

      return Right(count);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error(
        'RecordRepositoryImpl.getRecordCountByCategory failed',
        e,
        s,
      );

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, Map<String, int>>>
  getCategoryRecordCounts() async {
    try {
      final counts = await localDatasource.getCategoryRecordCounts();

      return Right(counts);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error(
        'RecordRepositoryImpl.getCategoryRecordCounts failed',
        e,
        s,
      );

      return Left(CacheFailure(message: e.toString()));
    }
  }

  Future<void> _enqueueSync(
    String action,
    String recordId, [
    Map<String, dynamic>? data,
  ]) async {
    final syncQueueDao = _syncQueueDao;
    if (syncQueueDao == null) return;
    await syncQueueDao.enqueue(
      tableName: 'records',
      recordId: recordId,
      action: action,
      payload: data != null ? jsonEncode(data) : '',
    );
    SyncEventBus().trigger();
  }
}
