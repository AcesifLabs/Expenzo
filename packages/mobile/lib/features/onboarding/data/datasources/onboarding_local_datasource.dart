import 'package:expense_tracker/core/database/app_database.dart';

/// Tells existing installs apart from fresh ones.
class OnboardingLocalDatasource {
  final AppDatabase db;

  OnboardingLocalDatasource({required this.db});

  /// True when the user has any transaction, budget or recurring item.
  /// Categories don't count: every install is seeded with them.
  Future<bool> hasUserData() async {
    final row = await db
        .customSelect(
          'SELECT EXISTS(SELECT 1 FROM records) '
          'OR EXISTS(SELECT 1 FROM budgets) '
          'OR EXISTS(SELECT 1 FROM recurring_transactions) AS has_data',
          readsFrom: {db.records, db.budgets, db.recurringTransactions},
        )
        .getSingle();

    return row.read<bool>('has_data');
  }
}
