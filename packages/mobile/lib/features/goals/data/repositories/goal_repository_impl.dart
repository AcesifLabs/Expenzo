import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/sync/sync_event.dart';
import 'package:expense_tracker/core/sync/sync_table_names.dart';

import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_local_datasource.dart';

/// Every write is saved locally and queued for `/sync/push` under `goals`.
class GoalRepositoryImpl implements GoalRepository {
  final GoalLocalDatasource localDatasource;
  final SyncQueueDao? _syncQueueDao;

  GoalRepositoryImpl({
    required this.localDatasource,
    SyncQueueDao? syncQueueDao,
  }) : _syncQueueDao = syncQueueDao;

  @override
  Future<Either<Failure, Goal?>> getActiveGoal() =>
      _run(localDatasource.getActiveGoal);

  @override
  Stream<Goal?> watchActiveGoal() => localDatasource.watchActiveGoal();

  @override
  Future<Either<Failure, Goal>> getGoalById(String id) async {
    final result = await _run(() => localDatasource.getGoalById(id));

    return result.flatMap(
      (goal) => goal == null
          ? Left(
              CacheFailure(
                message: 'Goal $id not found',
                errorCode: FailureCodes.notFound,
              ),
            )
          : Right(goal),
    );
  }

  @override
  Future<Either<Failure, Goal>> createGoal(Goal goal) => _run(() async {
    final withId = goal.copyWith(id: goal.id ?? const Uuid().v4());
    await localDatasource.createGoal(withId);
    await _enqueueSync('insert', withId.id ?? '', _payload(withId));

    return withId;
  });

  @override
  Future<Either<Failure, Goal>> updateGoal(Goal goal) => _run(() async {
    final id = goal.id;
    if (id == null) {
      throw const CacheException(message: 'A goal needs an id to update');
    }
    await localDatasource.updateGoal(goal);
    await _enqueueSync('update', id, _payload(goal));

    return goal;
  });

  @override
  Future<Either<Failure, Unit>> deleteGoal(String id) => _run(() async {
    await localDatasource.deleteGoal(id);
    await _enqueueSync('delete', id);

    return unit;
  });

  /// Field names match `GoalsSyncHandler.toSyncPayload`.
  Map<String, dynamic> _payload(Goal goal) => {
    'name': goal.name,
    'targetAmount': goal.targetAmount,
    'savedAmount': goal.savedAmount,
    'targetDate': goal.targetDate?.toUtc().toIso8601String(),
    'monthlyContribution': goal.monthlyContribution,
  };

  Future<Either<Failure, T>> _run<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      appLogger.error('Goal repository error', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Awaited, like recurring items, so a write and its queue row don't drift.
  Future<void> _enqueueSync(
    String action,
    String id, [
    Map<String, dynamic>? data,
  ]) async {
    final syncQueueDao = _syncQueueDao;
    if (syncQueueDao == null) return;
    await syncQueueDao.enqueue(
      tableName: SyncTableNames.goals,
      recordId: id,
      action: action,
      payload: data != null ? jsonEncode(data) : '',
    );
    SyncEventBus().trigger();
  }
}
