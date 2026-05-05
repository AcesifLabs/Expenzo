import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/sync/sync_event.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
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

  void _enqueueSync(String action, String recordId, [Map<String, dynamic>? data]) {
    if (_syncQueueDao == null) return;
    _syncQueueDao!.enqueue(tableName: 'budgets', recordId: recordId, action: action, payload: data != null ? jsonEncode(data) : '');
    SyncEventBus().trigger();
  }

  @override
  Future<Either<Failure, List<Budget>>> getBudgets() async {
    try {
      final budgets = await localDatasource.getBudgets();
      return Right(budgets);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

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
    }
  }

  @override
  Future<Either<Failure, Budget>> createBudget(Budget budget) async {
    try {
      await localDatasource.createBudget(budget);
      _enqueueSync('insert', budget.id!, {'categoryId': budget.categoryId, 'amount': budget.amount, 'period': budget.period, 'startDate': budget.startDate.toUtc().toIso8601String(), 'rolloverEnabled': budget.rolloverEnabled, 'rolloverAmount': budget.rolloverAmount, 'isEnabled': budget.isEnabled});
      return Right(budget);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, Budget>> updateBudget(Budget budget) async {
    try {
      await localDatasource.updateBudget(budget);
      _enqueueSync('update', budget.id!, {'categoryId': budget.categoryId, 'amount': budget.amount, 'period': budget.period, 'startDate': budget.startDate.toUtc().toIso8601String(), 'rolloverEnabled': budget.rolloverEnabled, 'rolloverAmount': budget.rolloverAmount, 'isEnabled': budget.isEnabled});
      return Right(budget);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteBudget(String id) async {
    try {
      await localDatasource.deleteBudget(id);
      _enqueueSync('delete', id);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Stream<List<Budget>> watchBudgets() {
    return localDatasource.watchBudgets();
  }
}
