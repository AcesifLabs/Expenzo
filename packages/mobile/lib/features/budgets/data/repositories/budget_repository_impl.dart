import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/sync/sync_event.dart';
import 'package:expense_tracker/core/database/app_database.dart' show Record;
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/core/sync/handlers/records_sync_handler.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDatasource localDatasource;
  final SyncQueueDao? _syncQueueDao;

  BudgetRepositoryImpl({
    required this.localDatasource,
    SyncQueueDao? syncQueueDao,
  }) : _syncQueueDao = syncQueueDao;

  /// Returns Left(Failure) on error.
  @override
  Future<Either<Failure, List<Budget>>> getBudgets() async {
    try {
      final budgets = await localDatasource.getBudgets();

      return Right(budgets);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('Error getting budgets', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<Failure, Budget>> getBudgetById(String id) async {
    try {
      final budget = await localDatasource.getBudgetById(id);
      if (budget == null) {
        return const Left(CacheFailure(message: 'Budget not found'));
      }

      return Right(budget);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('Error getting budget by id', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<Failure, Budget>> createBudget(Budget budget) async {
    try {
      // Generate id once if not provided, so datasource and sync use the same id
      final id = budget.id ?? const Uuid().v4();
      final budgetWithId = budget.id != null ? budget : budget.copyWith(id: id);

      await localDatasource.createBudget(budgetWithId);
      _enqueueSync('insert', id, {
        'name': budget.name,
        'amount': budget.amount,
        'period': budget.period.name,
        'startDate': budget.startDate.toUtc().toIso8601String(),
        'rolloverEnabled': budget.rolloverEnabled,
        'rolloverAmount': budget.rolloverAmount,
        'isEnabled': budget.isEnabled,
      });

      return Right(budgetWithId);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('Error creating budget', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<Failure, Budget>> updateBudget(Budget budget) async {
    try {
      await localDatasource.updateBudget(budget);
      // Update requires an existing budget with id
      final id = budget.id;
      if (id == null) {
        return Left(CacheFailure(message: 'Cannot update budget without id'));
      }
      _enqueueSync('update', id, {
        'name': budget.name,
        'amount': budget.amount,
        'period': budget.period.name,
        'startDate': budget.startDate.toUtc().toIso8601String(),
        'rolloverEnabled': budget.rolloverEnabled,
        'rolloverAmount': budget.rolloverAmount,
        'isEnabled': budget.isEnabled,
      });

      return Right(budget);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('Error updating budget', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<Failure, Unit>> deleteBudget(String id) async {
    try {
      final unlinkedRecords = await localDatasource.deleteBudget(id);
      _enqueueSync('delete', id);
      _enqueueUnlinkedRecords(unlinkedRecords);

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('Error deleting budget', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<Budget>> watchBudgets() {
    return localDatasource.watchBudgets();
  }

  /// Enqueues a records-table sync update for each record that was unlinked by
  /// a budget deletion, so the null budget link propagates to other devices.
  void _enqueueUnlinkedRecords(List<Record> records) {
    final syncQueueDao = _syncQueueDao;
    if (syncQueueDao == null || records.isEmpty) return;
    final handler = RecordsSyncHandler();
    for (final record in records) {
      syncQueueDao.enqueue(
        tableName: 'records',
        recordId: record.id,
        action: 'update',
        payload: jsonEncode(handler.toSyncPayload(record)),
      );
    }
    SyncEventBus().trigger();
  }

  void _enqueueSync(
    String action,
    String recordId, [
    Map<String, dynamic>? data,
  ]) {
    final syncQueueDao = _syncQueueDao;
    if (syncQueueDao == null) return;
    syncQueueDao.enqueue(
      tableName: 'budgets',
      recordId: recordId,
      action: action,
      payload: data != null ? jsonEncode(data) : '',
    );
    SyncEventBus().trigger();
  }
}
