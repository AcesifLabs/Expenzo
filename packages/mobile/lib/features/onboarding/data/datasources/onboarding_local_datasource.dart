import 'package:expense_tracker/core/database/app_database.dart';

class OnboardingLocalDatasource {
  final AppDatabase db;

  OnboardingLocalDatasource({required this.db});

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
