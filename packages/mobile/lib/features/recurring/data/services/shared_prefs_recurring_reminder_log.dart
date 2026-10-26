import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/send_recurring_reminders.dart';

class SharedPrefsRecurringReminderLog implements RecurringReminderLog {
  final SharedPreferences prefs;

  static const storageKey = 'recurring_reminders_sent';

  static const _maxEntries = 200;

  SharedPrefsRecurringReminderLog(this.prefs);

  @override
  Future<bool> wasSent(String key) async {
    await prefs.reload();

    return (prefs.getStringList(storageKey) ?? const []).contains(key);
  }

  @override
  Future<void> markSent(String key) async {
    await prefs.reload();
    final sent = [...?prefs.getStringList(storageKey)];
    if (sent.contains(key)) return;
    sent.add(key);
    final trimmed = sent.length > _maxEntries
        ? sent.sublist(sent.length - _maxEntries)
        : sent;
    await prefs.setStringList(storageKey, trimmed);
  }
}
