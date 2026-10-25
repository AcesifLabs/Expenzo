import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/router/settings_route.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/check_budget_alerts.dart';
import 'package:expense_tracker/features/receipt_scan/presentation/pages/receipt_scan_camera_page.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import 'support/app.dart';

/// Android's own permission dialogs, which widget tests can't reach.
///
/// Clearing app data between tests keeps permissions, so the order matters:
/// the camera is refused for good first (nothing later needs it), and SMS
/// ends granted, as sms_scan_test.dart (which runs after this file) needs.
/// The permanently-refused SMS screen is a widget test
/// (test/shared/presentation/widgets/sms_permission_gate_test.dart).
void main() {
  patrolTest('refusing the camera twice offers Open settings', ($) async {
    await launchOnboarded($);
    final navigator = $.tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );

    for (var i = 0; i < 2; i++) {
      unawaited(
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) =>
                const ReceiptScanCameraPage(expenseCategoryNames: []),
          ),
        ),
      );
      await settle($.tester);
      if (await permissionDialogShown($)) {
        await $.platform.mobile.denyPermission();
      }
      await settle($.tester);
      await $.takeNativeScreenshot('camera_refused_$i');
      if (i == 0) await tapText($, t.common.close);
    }

    expect(find.text(t.receiptScan.permissionBlocked), findsOneWidget);
    expect(find.text(t.common.openSettings), findsOneWidget);
  });

  patrolTest(
    'the first budget asks for notifications; going over it alerts in the '
    'notification shade',
    ($) async {
      await launchOnboarded($);
      await openRoute($, '/budgets/new');
      final fields = find.byType(TextFormField);
      await $.tester.enterText(fields.at(0), '100');
      await $.tester.enterText(fields.at(1), 'Groceries');
      await $.takeNativeScreenshot('budget_form_filled');
      await tapLowest($, t.budgets.form.add);
      await $.takeNativeScreenshot('budget_saved');
      if (await permissionDialogShown($)) {
        await $.platform.mobile.grantPermissionWhenInUse();
      }
      final db = di.getIt<AppDatabase>();
      final budget = await db.select(db.budgets).getSingle();

      // 150 spent of 100, then the check the transaction sheet runs.
      await db
          .into(db.records)
          .insert(
            RecordsCompanion.insert(
              id: 'e2e-overspend',
              amount: -150,
              description: 'Weekly shop',
              date: DateTime.now(),
              recordType: 'OUT',
              budgetId: Value(budget.id),
            ),
          );
      await di.getIt<CheckBudgetAlerts>()();
      await settle($.tester);

      await $.platform.mobile.openNotifications();
      final notifications = await $.platform.mobile.getNotifications();
      // Left open, the shade would hide the next test's permission dialog.
      await $.platform.mobile.closeNotifications();
      expect(
        notifications.any(
          (n) => '${n.title} ${n.content}'.contains('Groceries'),
        ),
        isTrue,
        reason:
            'notifications: '
            '${notifications.map((n) => '${n.appName}: ${n.title} ${n.content}')}',
      );
    },
  );

  patrolTest('SMS refused once keeps the gate; allowed, the senders show', (
    $,
  ) async {
    await launchOnboarded($);
    await openRoute($, SettingsRoute.autoImport.location);

    await tapText($, t.common.smsGate.allow);
    if (await permissionDialogShown($)) {
      await $.platform.mobile.denyPermission();
    }
    await settle($.tester);
    expect(find.text(t.common.smsGate.allow), findsOneWidget);

    await tapText($, t.common.smsGate.allow);
    if (await permissionDialogShown($)) {
      await $.platform.mobile.grantPermissionWhenInUse();
    }
    await settle($.tester);
    await $.takeNativeScreenshot('sms_allowed');
    expect(find.text(t.common.smsGate.allow), findsNothing);
  });
}
