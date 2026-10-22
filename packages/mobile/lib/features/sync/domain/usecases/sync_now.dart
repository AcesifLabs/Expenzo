import 'package:expense_tracker/core/sync/sync_run_result.dart';

import '../repositories/sync_overview_repository.dart';

/// Runs a sync cycle now. Not a `UseCase`: it never fails with a `Failure`;
/// the result says how it went.
class SyncNow {
  final SyncOverviewRepository repository;

  const SyncNow(this.repository);

  Future<SyncRunResult> call() => repository.syncNow();
}
