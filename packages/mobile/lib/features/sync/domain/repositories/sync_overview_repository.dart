import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/sync/sync_run_result.dart';

import '../entities/sync_overview.dart';

abstract class SyncOverviewRepository {
  /// True while a sync cycle runs, background ones included.
  ValueListenable<bool> get isSyncing;

  Future<Either<Failure, SyncOverview>> getOverview();

  /// Changes waiting in the sync queue, updated as it changes.
  Stream<int> watchPendingCount();

  Future<SyncRunResult> syncNow();
}
