import 'package:expense_tracker/core/database/daos/budget_dao.dart';

import '../../domain/entities/my_group.dart';
import '../../domain/usecases/get_my_group.dart';

/// Refreshes `/groups/me` after a sync cycle, which runs after every local
/// change, so not every time:
/// - never for a user outside any group with no Shared Budgets on the phone;
/// - at most once per [refreshInterval] otherwise.
/// Shared Budgets with no cached group mean the user joined on another
/// device; the refresh then learns the group. Family screens fetch on their
/// own whenever they open.
class GroupRefreshPolicy {
  final MyGroup? Function() cachedGroup;
  final BudgetDao budgetDao;
  final GetMyGroup getMyGroup;
  final DateTime Function() clock;

  static const refreshInterval = Duration(minutes: 15);

  DateTime? _lastRefresh;

  GroupRefreshPolicy({
    required this.cachedGroup,
    required this.budgetDao,
    required this.getMyGroup,
    this.clock = DateTime.now,
  });

  Future<void> refreshIfDue() async {
    if (cachedGroup() == null &&
        (await budgetDao.getBudgetsWithGroup()).isEmpty) {
      return;
    }
    final now = clock();
    final last = _lastRefresh;
    if (last != null && now.difference(last) < refreshInterval) return;
    _lastRefresh = now;
    await getMyGroup(const GetMyGroupParams());
  }
}
