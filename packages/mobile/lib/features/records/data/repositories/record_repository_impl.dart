import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/sync/sync_event.dart';
import 'package:expense_tracker/core/sync/connectivity_service.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import '../../domain/repositories/record_repository.dart';
import '../datasources/record_local_datasource.dart';
import '../datasources/record_remote_datasource.dart';

class RecordRepositoryImpl implements RecordRepository {
  final RecordLocalDatasource localDatasource;
  final RecordRemoteDatasource remoteDatasource;
  final ConnectivityService connectivity;
  final SyncQueueDao? _syncQueueDao;

  RecordRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.connectivity,
    SyncQueueDao? syncQueueDao,
  }) : _syncQueueDao = syncQueueDao;

  /// Returns Left(Failure) on error.
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
      debugPrint('Error: $e\n$s');

      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<Failure, List<Record>>> getFilteredRecords(
    RecordFilter filter,
  ) async {
    try {
      final online = await _checkConnectivity();
      if (online) {
        final resp = await remoteDatasource.getRecords(
          RemoteRecordQuery(
            limit: filter.limit,
            startDate: filter.startDate?.toUtc().toIso8601String(),
            endDate: filter.endDate?.toUtc().toIso8601String(),
            categoryIds: filter.categoryIds,
            recordType: filter.recordType,
          ),
        );

        return Right(resp.data);
      }

      final records = await localDatasource.getFilteredRecords(filter);

      return Right(records);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      debugPrint('Error: $e\n$s');

      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<CacheFailure, Record>> getRecordById(String id) async {
    try {
      final record = await localDatasource.getRecordById(id);
      if (record == null) {
        return const Left(CacheFailure(message: 'Record not found'));
      }

      return Right(record);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      debugPrint('Error: $e\n$s');

      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<CacheFailure, Record>> addRecord(Record record) async {
    try {
      final added = await localDatasource.addRecord(record);
      final addedId = added.id;
      if (addedId != null) {
        _enqueueSync('insert', addedId, {
          'amount': added.amount,
          'description': added.description,
          'date': added.date.toUtc().toIso8601String(),
          'categoryId': added.categoryId,
          'source': added.source.name,
          'recordType': added.recordType.dbValue,
        });
      }

      return Right(added);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      debugPrint('Error: $e\n$s');

      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<CacheFailure, Record>> updateRecord(Record record) async {
    try {
      final updated = await localDatasource.updateRecord(record);
      final updatedId = updated.id;
      if (updatedId != null) {
        _enqueueSync('update', updatedId, {
          'amount': updated.amount,
          'description': updated.description,
          'date': updated.date.toUtc().toIso8601String(),
          'categoryId': updated.categoryId,
          'source': updated.source.name,
          'recordType': updated.recordType.dbValue,
        });
      }

      return Right(updated);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      debugPrint('Error: $e\n$s');

      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<CacheFailure, Unit>> deleteRecord(String id) async {
    try {
      await localDatasource.deleteRecord(id);
      _enqueueSync('delete', id);

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      debugPrint('Error: $e\n$s');

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<Record>> watchRecords({int? limit, int? offset}) {
    return localDatasource.watchRecords(limit: limit, offset: offset);
  }

  /// Returns Left(Failure) on error.
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
      debugPrint('Error: $e\n$s');

      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
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
      debugPrint('Error: $e\n$s');

      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
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
      debugPrint('Error: $e\n$s');

      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
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
      debugPrint('Error: $e\n$s');

      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
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
      debugPrint('Error: $e\n$s');

      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
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
      debugPrint('Error: $e\n$s');

      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<CacheFailure, Unit>> addRecordsBatch(
    List<Record> records,
  ) async {
    try {
      await localDatasource.addRecordsBatch(records);
      for (final r in records) {
        final recordId = r.id;
        if (recordId != null) {
          _enqueueSync('insert', recordId, {
            'amount': r.amount,
            'description': r.description,
            'date': r.date.toUtc().toIso8601String(),
            'categoryId': r.categoryId,
            'source': r.source.name,
            'recordType': r.recordType.dbValue,
          });
        }
      }

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      debugPrint('Error: $e\n$s');

      return Left(CacheFailure(message: e.toString()));
    }
  }

  Future<bool> _checkConnectivity() async {
    try {
      return await connectivity.checkNow().timeout(
        const Duration(seconds: 3),
        onTimeout: () => false,
      );
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      debugPrint('Connectivity check failed, assuming offline: $e');

      return false;
    }
  }

  void _enqueueSync(
    String action,
    String recordId, [
    Map<String, dynamic>? data,
  ]) {
    final syncQueueDao = _syncQueueDao;
    if (syncQueueDao == null) return;
    syncQueueDao.enqueue(
      tableName: 'records',
      recordId: recordId,
      action: action,
      payload: data != null ? jsonEncode(data) : '',
    );
    SyncEventBus().trigger();
  }
}
