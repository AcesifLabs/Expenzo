import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/features/budgets/data/datasources/budget_remote_datasource.dart';
import 'package:expense_tracker/features/budgets/data/services/budget_name_repair.dart';
import 'package:expense_tracker/features/data_wipe/data/services/local_data_prefs.dart';
import 'package:expense_tracker/features/records/data/datasources/record_remote_datasource.dart';
import 'package:expense_tracker/features/records/data/services/record_budget_link_repair.dart';

class _MockBudgetDao extends Mock implements BudgetDao {}

class _MockRecordDao extends Mock implements RecordDao {}

class _MockBudgetRemote extends Mock implements BudgetRemoteDatasource {}

class _MockRecordRemote extends Mock implements RecordRemoteDatasource {}

void main() {
  test('removes repair flags for every account and both sent logs', () async {
    SharedPreferences.setMockInitialValues({
      'budget_names_repaired_u1': true,
      'budget_names_repaired_u2': true,
      'record_budget_links_repaired_u1': true,
      'budget_alerts_sent': ['b1:80'],
      'recurring_reminders_sent': ['rt1:2026-03-01'],
      'user_settings': '{}',
    });
    final prefs = await SharedPreferences.getInstance();

    await LocalDataPrefs(prefs).clear();

    expect(prefs.getKeys(), {'user_settings'});
    for (final userId in ['u1', 'u2']) {
      final budgetRepair = BudgetNameRepair(
        budgetDao: _MockBudgetDao(),
        remote: _MockBudgetRemote(),
        prefs: prefs,
        currentUserId: () => userId,
      );
      final linkRepair = RecordBudgetLinkRepair(
        recordDao: _MockRecordDao(),
        remote: _MockRecordRemote(),
        prefs: prefs,
        currentUserId: () => userId,
      );

      expect(budgetRepair.isPending, isTrue);
      expect(linkRepair.isPending, isTrue);
    }
  });
}
