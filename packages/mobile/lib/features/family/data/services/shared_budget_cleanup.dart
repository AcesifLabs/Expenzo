import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';

import '../../domain/entities/my_group.dart';

/// Pull has no tombstones (ADR 0008), so after each `/groups/me` the phone
/// decides which local Shared Budgets it should still have:
/// - another member's budget of a group I am no longer in, or one its owner
///   unshared or deleted: deleted from this phone;
/// - my own budget after I left or the group was deleted: kept, now
///   personal (the server already cleared its groupId);
/// - a budget with changes not yet pushed: left alone until they are.
///
/// It writes through [BudgetDao] only, so nothing is queued for sync, and
/// records keep their budgetId.
class SharedBudgetCleanup {
  final BudgetDao budgetDao;
  final SyncQueueDao syncQueueDao;

  const SharedBudgetCleanup({
    required this.budgetDao,
    required this.syncQueueDao,
  });

  Future<void> apply({MyGroup? previous, MyGroup? current}) async {
    final rows = await budgetDao.getBudgetsWithGroup();
    if (rows.isEmpty) return;
    final pending = await syncQueueDao.pendingRecordIds('budgets');
    final toDelete = <String>[];
    final toClear = <String>[];
    for (final row in rows) {
      if (pending.contains(row.id)) continue;
      final mine =
          (previous?.ownsBudget(row.id) ?? false) ||
          (current?.ownsBudget(row.id) ?? false);
      if (current == null || row.groupId != current.group.id) {
        (mine ? toClear : toDelete).add(row.id);
      } else if (!current.listsBudget(row.id) &&
          !_maybeJustShared(row.id, previous: previous, current: current)) {
        toDelete.add(row.id);
      }
    }
    await budgetDao.deleteBudgetsByIds(toDelete);
    await budgetDao.clearGroupId(toClear);
  }

  /// An unlisted budget of the current group that may be mine, shared on
  /// this phone after the group was last fetched: kept for the next fetch.
  /// One the previous fetch listed as someone else's is not.
  bool _maybeJustShared(
    String id, {
    required MyGroup? previous,
    required MyGroup current,
  }) {
    if (previous?.ownsBudget(id) ?? false) return true;
    if (previous?.listsBudget(id) ?? false) return false;

    return current.myRole.isAdmin;
  }
}
