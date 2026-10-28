import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/utils/budget_name.dart';
import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import 'package:expense_tracker/features/budgets/data/datasources/budget_remote_datasource.dart';

class BudgetNameRepair {
  final BudgetDao budgetDao;
  final BudgetRemoteDatasource remote;
  final SharedPreferences prefs;

  final String? Function() currentUserId;

  static const doneKeyPrefix = 'budget_names_repaired_';

  Future<void>? _running;

  bool get isPending {
    final userId = currentUserId();

    return userId == null || !(prefs.getBool('$doneKeyPrefix$userId') ?? false);
  }

  BudgetNameRepair({
    required this.budgetDao,
    required this.remote,
    required this.prefs,
    required this.currentUserId,
  });

  Future<void> runOnce() =>
      _running ??= _run().whenComplete(() => _running = null);

  Future<void> _run() async {
    final userId = currentUserId();
    if (userId == null || !isPending) return;

    final budgets = await budgetDao.getAllBudgets();

    final names = [
      for (final budget in budgets)
        if (!isPlaceholderBudgetName(budget.name) &&
            budget.name.length <= AppConstants.budgetNameMaxLength)
          (id: budget.id, name: budget.name),
    ];
    for (
      var i = 0;
      i < names.length;
      i += AppConstants.fillBudgetNamesBatchSize
    ) {
      final end = i + AppConstants.fillBudgetNamesBatchSize < names.length
          ? i + AppConstants.fillBudgetNamesBatchSize
          : names.length;
      await remote.fillMissingNames(names.sublist(i, end));
    }
    await prefs.setBool('$doneKeyPrefix$userId', true);
  }
}
