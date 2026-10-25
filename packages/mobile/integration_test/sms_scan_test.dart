import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:expense_tracker/core/database/app_database.dart'
    show AppDatabase;
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/router/settings_route.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/message_source.dart';
import 'package:expense_tracker/features/message_templates/domain/repositories/message_template_repository.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_rule.dart';
import 'package:expense_tracker/features/parsing_rules/domain/repositories/parsing_rules_repository.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import 'support/app.dart';

/// The sender `integration_test/support/seed_sms.sh` writes to the
/// emulator's inbox before the run.
const _sender = '16216';

Future<void> _watchSender() async {
  final now = DateTime.now();
  await di.getIt<MessageTemplateRepository>().saveMessageSource(
    MessageSource(
      id: 'e2e-source',
      contactId: _sender,
      contactName: 'Bank',
      isMonitored: true,
      createdAt: now,
      updatedAt: now,
    ),
  );
  await di.getIt<ParsingRulesRepository>().createRule(
    ParsingRule(
      id: 'e2e-rule',
      name: 'Bank debits',
      triggerWords: const ['debited'],
      amountPattern: r'Tk\.?\s*([\d,]+\.?\d*)',
      sourceType: SourceType.sms,
      isEnabled: true,
      priority: 1,
      createdAt: now,
      updatedAt: now,
    ),
  );
}

Future<void> _scanAllTime(PatrolIntegrationTester $) async {
  await tapText($, t.smsParser.autoImport.scanPast);
  await tapText($, t.smsParser.range.allTime);
  await settle($.tester, 4);
}

Future<int> _importedCount() async {
  final db = di.getIt<AppDatabase>();

  return (await (db.select(
    db.records,
  )..where((r) => r.sourceId.isNotNull())).get()).length;
}

/// Reads real messages from the inbox (seeded with `adb emu sms send`),
/// imports them, and offers none of them again on a second scan.
void main() {
  patrolTest('scanned messages become records once', ($) async {
    await launchOnboarded($);
    await _watchSender();
    await openRoute($, SettingsRoute.autoImport.location);
    await tapText($, t.common.smsGate.allow);
    if (await permissionDialogShown($)) {
      await $.platform.mobile.grantPermissionWhenInUse();
    }
    await settle($.tester);
    await $.takeNativeScreenshot('auto_import_allowed');

    await _scanAllTime($);
    await $.takeNativeScreenshot('scan_results');
    expect(find.textContaining('Tk'), findsWidgets, reason: 'seeded SMS');
    await $.tester.tap(find.textContaining(RegExp(r'^Add \d+ selected')));
    await settle($.tester, 3);
    final imported = await _importedCount();
    expect(imported, greaterThan(0));

    // Adding closes the results and returns to Auto import.
    await _scanAllTime($);
    await $.takeNativeScreenshot('second_scan');
    expect(find.text(t.smsParser.results.empty), findsOneWidget);
    expect(await _importedCount(), imported);
  });
}
