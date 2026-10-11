import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/utils/budget_name.dart';
import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/budgets/data/datasources/budget_remote_datasource.dart';

/// Sends this device's budget names to the server once per account.
///
/// The server dropped budget names until it had a column for them, so its
/// older rows read [AppConstants.defaultBudgetName]. The server fills a name only where it
/// still has the default: it never creates a budget or changes any other
/// field (ADR 0012). The repair counts as done for the signed-in account only
/// after every batch is accepted.
class BudgetNameRepair {
  static const _doneKeyPrefix = 'budget_names_repaired_';

  final BudgetDao budgetDao;
  final BudgetRemoteDatasource remote;
  final SharedPreferences prefs;

  /// The signed-in account, or null when signed out.
  final String? Function() currentUserId;

  Future<void>? _running;

  BudgetNameRepair({
    required this.budgetDao,
    required this.remote,
    required this.prefs,
    required this.currentUserId,
  });

  /// True until the signed-in account's names have been sent. Signed out it
  /// stays true, so local names are kept until someone can send them.
  bool get isPending {
    final userId = currentUserId();
    return userId == null ||
        !(prefs.getBool('$_doneKeyPrefix$userId') ?? false);
  }

  /// Throws [ServerException] when a batch is rejected or the server cannot be
  /// reached; the repair then stays pending and runs after the next sync.
  /// Calls made while a run is in progress wait for that run.
  Future<void> runOnce() =>
      _running ??= _run().whenComplete(() => _running = null);

  Future<void> _run() async {
    final userId = currentUserId();
    if (userId == null || !isPending) return;

    final budgets = await budgetDao.getAllBudgets();
    // Names the server would reject are skipped so one of them cannot block
    // the rest; that budget keeps the default on the server until edited.
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
    await prefs.setBool('$_doneKeyPrefix$userId', true);
  }
}
