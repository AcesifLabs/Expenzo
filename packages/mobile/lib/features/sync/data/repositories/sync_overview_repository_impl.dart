import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';

import '../../domain/entities/sync_overview.dart';
import '../../domain/repositories/sync_overview_repository.dart';
import '../services/sync_outcome_reader.dart';

class SyncOverviewRepositoryImpl implements SyncOverviewRepository {
  final SyncEngine engine;
  final SyncQueueDao queue;
  final SyncOutcomeReader outcomes;

  @override
  ValueListenable<bool> get isSyncing => engine.isSyncing;

  const SyncOverviewRepositoryImpl({
    required this.engine,
    required this.queue,
    required this.outcomes,
  });

  @override
  Future<Either<Failure, SyncOverview>> getOverview() async {
    try {
      final (signedIn, success, failure, failures, pending) = await (
        outcomes.hasToken(),
        outcomes.lastSuccessfulSyncAt(),
        outcomes.lastFailedSyncAt(),
        outcomes.consecutiveFailures(),
        queue.getUnsyncedCount(),
      ).wait;

      return Right(
        SyncOverview(
          isSignedIn: signedIn,
          lastSuccessfulSyncAt: success,
          lastFailedSyncAt: failure,
          consecutiveFailures: failures,
          pendingCount: pending,
        ),
      );
    } catch (e, s) {
      appLogger.error('Sync overview error', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Stream<int> watchPendingCount() => queue.watchUnsyncedCount();

  @override
  Stream<int> watchFailedCount() => queue.watchFailedCount();

  @override
  Future<void> retryFailed() => queue.retryFailed();

  @override
  Future<SyncRunResult> syncNow() => engine.syncNow();
}
