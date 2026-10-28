import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/main.dart' as app;

import 'demo_seed.dart';

const _theme = String.fromEnvironment('THEME', defaultValue: 'light');

Future<void> _settle(WidgetTester tester, [double seconds = 2]) async {
  for (var i = 0; i < seconds * 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _go(WidgetTester tester, String location) async {
  final context = tester.element(find.byType(Navigator).first);
  GoRouter.of(context).go(location);
  await _settle(tester);
}

Future<void> _waitForFullHint(WidgetTester tester) async {
  String? hint() => tester
      .widgetList<TextField>(find.byType(TextField))
      .map((field) => field.decoration?.hintText)
      .firstWhere((text) => text != null, orElse: () => null);

  var last = hint();
  var steady = 0;
  for (var i = 0; i < 100 && steady < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    final now = hint();
    steady = now == last && (now ?? '').length > 3 ? steady + 1 : 0;
    last = now;
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tutorial screenshots ($_theme)', (tester) async {
    await seedDemoSettings(theme: _theme);
    app.main();
    await _settle(tester, 15);
    LocaleSettings.setLocaleSync(AppLocale.en);

    await seedDemoData(di.getIt<AppDatabase>());
    final notNow = find.text(t.common.notNow);
    if (notNow.evaluate().isNotEmpty) {
      await tester.tap(notNow.first);
      await _settle(tester);
    }
    unawaited(
      tester
          .state<RefreshIndicatorState>(find.byType(RefreshIndicator).first)
          .show(),
    );
    await _settle(tester, 4);
    await binding.convertFlutterSurfaceToImage();
    await _settle(tester, 1);

    await binding.takeScreenshot('tutorial_dashboard_$_theme');

    await tester.tap(find.byTooltip(t.common.addTransaction));
    await _settle(tester);
    FocusManager.instance.primaryFocus?.unfocus();
    await _waitForFullHint(tester);
    await binding.takeScreenshot('tutorial_add_transaction_$_theme');

    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await _settle(tester);
    await _go(tester, AppRootTab.reports.location);
    await tester.tap(find.text(t.shell.reportsTabs.categories).first);
    await _settle(tester, 3);
    await binding.takeScreenshot('tutorial_reports_$_theme');
  });
}
