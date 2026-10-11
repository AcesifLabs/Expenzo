import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/features/budgets/data/services/shared_prefs_budget_alert_log.dart';

void main() {
  late SharedPrefsBudgetAlertLog log;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    log = SharedPrefsBudgetAlertLog(await SharedPreferences.getInstance());
  });

  test('remembers a sent alert across instances', () async {
    expect(await log.wasSent('b1|2026-10|nearLimit'), isFalse);

    await log.markSent(['b1|2026-10|nearLimit']);

    final reopened = SharedPrefsBudgetAlertLog(
      await SharedPreferences.getInstance(),
    );
    expect(await reopened.wasSent('b1|2026-10|nearLimit'), isTrue);
    expect(await reopened.wasSent('b1|2026-10|over'), isFalse);
  });

  test('marking the same key twice stores it once', () async {
    await log.markSent(['k']);
    await log.markSent(['k', 'k']);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('budget_alerts_sent'), ['k']);
  });

  test('keeps only the newest 200 keys', () async {
    for (var i = 0; i < 205; i++) {
      await log.markSent(['k$i']);
    }

    expect(await log.wasSent('k0'), isFalse);
    expect(await log.wasSent('k4'), isFalse);
    expect(await log.wasSent('k5'), isTrue);
    expect(await log.wasSent('k204'), isTrue);
  });

  test('several keys are stored in one write', () async {
    await log.markSent(['b1|over', 'b1|nearLimit']);

    expect(await log.wasSent('b1|over'), isTrue);
    expect(await log.wasSent('b1|nearLimit'), isTrue);
  });
}
