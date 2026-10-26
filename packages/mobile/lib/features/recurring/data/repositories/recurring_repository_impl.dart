import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/core/sync/sync_event.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/repositories/recurring_repository.dart';
import '../datasources/recurring_local_datasource.dart';
import 'package:expense_tracker/core/error/failure_message.dart';

class RecurringRepositoryImpl implements RecurringRepository {
  final RecurringLocalDatasource localDatasource;
  final SyncQueueDao? _syncQueueDao;

  RecurringRepositoryImpl({
    required this.localDatasource,
    SyncQueueDao? syncQueueDao,
  }) : _syncQueueDao = syncQueueDao;

  @override
  Future<Either<Failure, List<RecurringTransaction>>> getRecurringList() async {
    try {
      final recurring = await localDatasource.getRecurringList();

      return Right(recurring);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('Recurring repository error', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RecurringTransaction>> getRecurringById(
    String id,
  ) async {
    try {
      final recurring = await localDatasource.getRecurringById(id);
      if (recurring == null) {
        return const Left(
          CacheFailure(
            message: 'Recurring transaction not found',
            errorCode: FailureCodes.notFound,
          ),
        );
      }

      return Right(recurring);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('Recurring repository error', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RecurringTransaction>> createRecurring(
    RecurringTransaction recurring,
  ) async {
    try {
      final id = recurring.id ?? const Uuid().v4();
      final withId = recurring.id != null
          ? recurring
          : recurring.copyWith(id: id);

      await localDatasource.createRecurring(withId);
      await _enqueueSync('insert', id, _toPayload(withId));

      return Right(withId);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('Recurring repository error', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RecurringTransaction>> updateRecurring(
    RecurringTransaction recurring,
  ) async {
    try {
      await localDatasource.updateRecurring(recurring);
      final id = recurring.id;
      if (id != null) await _enqueueSync('update', id, _toPayload(recurring));

      return Right(recurring);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('Recurring repository error', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateRecurringBatch(
    List<RecurringTransaction> transactions,
  ) async {
    try {
      await localDatasource.updateRecurringBatch(transactions);

      for (final recurring in transactions) {
        final id = recurring.id;
        if (id != null) await _enqueueSync('update', id, _toPayload(recurring));
      }

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('Recurring repository error', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRecurring(String id) async {
    try {
      await localDatasource.deleteRecurring(id);
      await _enqueueSync('delete', id);

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('Recurring repository error', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<RecurringTransaction>> watchRecurringList() {
    return localDatasource.watchRecurringList();
  }

  @override
  Future<Either<Failure, List<RecurringTransaction>>> getDueRecurring() async {
    try {
      final dueRecurring = await localDatasource.getDueRecurring();

      return Right(dueRecurring);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('Recurring repository error', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  Map<String, dynamic> _toPayload(RecurringTransaction r) => {
    'description': r.description,
    'amount': r.amount,
    'categoryId': r.categoryId,
    'frequency': r.frequency.name,
    'startDate': r.startDate.toUtc().toIso8601String(),
    'endDate': r.endDate?.toUtc().toIso8601String(),
    'nextOccurrence': r.nextOccurrence.toUtc().toIso8601String(),
    'isActive': r.isActive,
    'autoCreateExpense': r.autoCreateExpense,
    'dayOfMonth': r.dayOfMonth,
  };

  Future<void> _enqueueSync(
    String action,
    String id, [
    Map<String, dynamic>? data,
  ]) async {
    final syncQueueDao = _syncQueueDao;
    if (syncQueueDao == null) return;
    await syncQueueDao.enqueue(
      tableName: 'recurring_transactions',
      recordId: id,
      action: action,
      payload: data != null ? jsonEncode(data) : '',
    );
    SyncEventBus().trigger();
  }
}
