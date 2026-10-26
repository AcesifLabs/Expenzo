import 'package:expense_tracker/core/sync/sync_run_result.dart';

import '../repositories/sync_overview_repository.dart';

class SyncNow {
  final SyncOverviewRepository repository;

  const SyncNow(this.repository);

  Future<SyncRunResult> call() => repository.syncNow();
}
