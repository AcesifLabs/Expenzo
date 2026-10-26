import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/check_budget_alerts.dart';

class SharedPrefsBudgetAlertLog implements BudgetAlertLog {
  final SharedPreferences prefs;

  static const storageKey = 'budget_alerts_sent';

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
