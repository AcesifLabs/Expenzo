import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/features/records/data/services/transaction_draft_store.dart';
import 'package:expense_tracker/features/budgets/data/services/budget_name_repair.dart';
import 'package:expense_tracker/features/budgets/data/services/shared_prefs_budget_alert_log.dart';
import 'package:expense_tracker/features/records/data/services/record_budget_link_repair.dart';
import 'package:expense_tracker/features/recurring/data/services/shared_prefs_recurring_reminder_log.dart';

class LocalDataPrefs {
  final SharedPreferences prefs;

  static const _repairFlagPrefixes = [
    BudgetNameRepair.doneKeyPrefix,
    RecordBudgetLinkRepair.doneKeyPrefix,
  ];

  static const _sentLogKeys = [
    SharedPrefsBudgetAlertLog.storageKey,
    SharedPrefsRecurringReminderLog.storageKey,
    TransactionDraftStore.storageKey,
  ];

  const LocalDataPrefs(this.prefs);

  Future<void> clear() async {
    final keys = prefs.getKeys().where(
      (key) =>
          _sentLogKeys.contains(key) ||
          _repairFlagPrefixes.any((prefix) => key.startsWith(prefix)),
    );
    for (final key in keys.toList()) {
      await prefs.remove(key);
    }
  }
}
