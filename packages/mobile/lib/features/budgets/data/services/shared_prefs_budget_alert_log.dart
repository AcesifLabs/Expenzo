import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/check_budget_alerts.dart';

/// Stores sent budget alert keys on the device.
class SharedPrefsBudgetAlertLog implements BudgetAlertLog {
  final SharedPreferences prefs;

  /// Cleared by `LocalDataPrefs` when local data is wiped.
  static const storageKey = 'budget_alerts_sent';

  /// Old keys only matter for their own budget period; keep the log small.
  static const _maxEntries = 200;

  SharedPrefsBudgetAlertLog(this.prefs);

  @override
  Future<bool> wasSent(String key) async {
    return (prefs.getStringList(storageKey) ?? const []).contains(key);
  }

  @override
  Future<void> markSent(Iterable<String> keys) async {
    final sent = [...?prefs.getStringList(storageKey)];
    final known = sent.toSet();
    final added = keys.where(known.add).toList();
    if (added.isEmpty) return;
    sent.addAll(added);
    final trimmed = sent.length > _maxEntries
        ? sent.sublist(sent.length - _maxEntries)
        : sent;
    await prefs.setStringList(storageKey, trimmed);
  }
}
