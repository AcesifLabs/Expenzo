import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/send_recurring_reminders.dart';

/// Stores sent recurring reminder keys on the device.
class SharedPrefsRecurringReminderLog implements RecurringReminderLog {
  final SharedPreferences prefs;

  static const _key = 'recurring_reminders_sent';

  /// Old keys only matter until their occurrence passes; keep the log small.
  static const _maxEntries = 200;

  SharedPrefsRecurringReminderLog(this.prefs);

  // The app and the background isolate each cache SharedPreferences; reload
  // so one never misses or overwrites what the other wrote.
  @override
  Future<bool> wasSent(String key) async {
    await prefs.reload();

    return (prefs.getStringList(_key) ?? const []).contains(key);
  }

  @override
  Future<void> markSent(String key) async {
    await prefs.reload();
    final sent = [...?prefs.getStringList(_key)];
    if (sent.contains(key)) return;
    sent.add(key);
    final trimmed = sent.length > _maxEntries
        ? sent.sublist(sent.length - _maxEntries)
        : sent;
    await prefs.setStringList(_key, trimmed);
  }
}
