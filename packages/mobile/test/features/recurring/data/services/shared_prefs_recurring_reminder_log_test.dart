import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/features/recurring/data/services/shared_prefs_recurring_reminder_log.dart';

void main() {
  late SharedPrefsRecurringReminderLog log;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    log = SharedPrefsRecurringReminderLog(
      await SharedPreferences.getInstance(),
    );
  });

  test('remembers a sent reminder across instances', () async {
    expect(await log.wasSent('r1|2026-10-13'), isFalse);

    await log.markSent('r1|2026-10-13');

    final reopened = SharedPrefsRecurringReminderLog(
      await SharedPreferences.getInstance(),
    );
    expect(await reopened.wasSent('r1|2026-10-13'), isTrue);
    expect(await reopened.wasSent('r1|2026-11-13'), isFalse);
  });

  test('marking the same key twice stores it once', () async {
    await log.markSent('k');
    await log.markSent('k');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('recurring_reminders_sent'), ['k']);
  });

  test('keeps only the newest 200 keys', () async {
    for (var i = 0; i < 205; i++) {
      await log.markSent('k$i');
    }

    expect(await log.wasSent('k4'), isFalse);
    expect(await log.wasSent('k5'), isTrue);
    expect(await log.wasSent('k204'), isTrue);
  });
}
