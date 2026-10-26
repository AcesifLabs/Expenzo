import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/sync/sync_run_result.dart';

import '../entities/sync_overview.dart';

abstract class SyncOverviewRepository {
  ValueListenable<bool> get isSyncing;

  Future<Either<Failure, SyncOverview>> getOverview();

  Stream<int> watchPendingCount();

  Stream<int> watchFailedCount();

  Future<void> retryFailed();

  Future<SyncRunResult> syncNow();
}
