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
import '../../domain/entities/plan_changes.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';
import 'package:expense_tracker/core/error/failure_message.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDatasource localDatasource;
  final SyncQueueDao? _syncQueueDao;

  BudgetRepositoryImpl({
    required this.localDatasource,
    SyncQueueDao? syncQueueDao,
  }) : _syncQueueDao = syncQueueDao;

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

  @override
  Future<Either<Failure, Budget>> getBudgetById(String id) async {
    try {
      final budget = await localDatasource.getBudgetById(id);
      if (budget == null) {
        return const Left(
          CacheFailure(
            message: 'Budget not found',
            errorCode: FailureCodes.notFound,
          ),
        );
      }

      return Right(budget);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('Error getting budget by id', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Budget>> createBudget(Budget budget) async {
    try {
      final id = budget.id ?? const Uuid().v4();
      final budgetWithId = budget.id != null ? budget : budget.copyWith(id: id);

      await localDatasource.createBudget(budgetWithId);
      _enqueueSync('insert', id, _payload(budget));

      return Right(budgetWithId);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('Error creating budget', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Budget>> updateBudget(Budget budget) async {
    try {
      await localDatasource.updateBudget(budget);
      final id = budget.id;
      if (id == null) {
        return Left(CacheFailure(message: 'Cannot update budget without id'));
      }
      _enqueueSync('update', id, _payload(budget));

      return Right(budget);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('Error updating budget', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

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

  @override
  Future<Either<Failure, Unit>> applyPlanChanges(PlanChanges changes) async {
    try {
      final creates = [
        for (final budget in changes.toCreate)
          budget.id == null ? budget.copyWith(id: const Uuid().v4()) : budget,
      ];
      final unlinked = await localDatasource.applyPlanChanges(
        deleteIds: [for (final budget in changes.toDelete) ?budget.id],
        updates: changes.toUpdate,
        creates: creates,
      );
      await _enqueuePlan(
        deleted: changes.toDelete,
        updated: changes.toUpdate,
        created: creates,
        unlinked: unlinked,
      );

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('Error saving the budget plan', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  Map<String, dynamic> _payload(Budget budget) => {
    'name': budget.name,
    'amount': budget.amount,
    'period': budget.period.name,
    'startDate': budget.startDate.toUtc().toIso8601String(),
    'rolloverEnabled': budget.rolloverEnabled,
    'rolloverAmount': budget.rolloverAmount,
    'isEnabled': budget.isEnabled,
    'groupId': budget.groupId,
  };

  Future<void> _enqueuePlan({
    required List<Budget> deleted,
    required List<Budget> updated,
    required List<Budget> created,
    required List<Record> unlinked,
  }) async {
    final syncQueueDao = _syncQueueDao;
    if (syncQueueDao == null) return;
    final records = RecordsSyncHandler();
    final changes = [
      for (final budget in deleted)
        if (budget.id case final id?)
          (tableName: 'budgets', recordId: id, action: 'delete', payload: ''),
      for (final (action, budgets) in [
        ('update', updated),
        ('insert', created),
      ])
        for (final budget in budgets)
          if (budget.id case final id?)
            (
              tableName: 'budgets',
              recordId: id,
              action: action,
              payload: jsonEncode(_payload(budget)),
            ),
      for (final record in unlinked)
        (
          tableName: 'records',
          recordId: record.id,
          action: 'update',
          payload: jsonEncode(records.toSyncPayload(record)),
        ),
    ];
    if (changes.isEmpty) return;
    await syncQueueDao.enqueueAll(changes);
    SyncEventBus().trigger();
  }

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
