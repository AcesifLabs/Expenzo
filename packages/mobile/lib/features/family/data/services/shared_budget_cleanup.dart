import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';

import '../../domain/entities/my_group.dart';

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
