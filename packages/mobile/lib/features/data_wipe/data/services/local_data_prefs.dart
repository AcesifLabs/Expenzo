import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/features/budgets/data/services/budget_name_repair.dart';
import 'package:expense_tracker/features/budgets/data/services/shared_prefs_budget_alert_log.dart';
import 'package:expense_tracker/features/records/data/services/record_budget_link_repair.dart';
import 'package:expense_tracker/features/recurring/data/services/shared_prefs_recurring_reminder_log.dart';

/// Every per-item or one-time pref that refers to local data is listed here,
/// so a wipe leaves none behind.
class LocalDataPrefs {
  final SharedPreferences prefs;

  /// One-time repair flags, stored per account as `<prefix><userId>`.
  static const _repairFlagPrefixes = [
    BudgetNameRepair.doneKeyPrefix,
    RecordBudgetLinkRepair.doneKeyPrefix,
  ];

  /// Logs of alerts and reminders already sent for a budget or recurring
  /// item.
  static const _sentLogKeys = [
    SharedPrefsBudgetAlertLog.storageKey,
    SharedPrefsRecurringReminderLog.storageKey,
  ];

  const LocalDataPrefs(this.prefs);

  /// Removes them all; the repairs become pending again for every account.
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
