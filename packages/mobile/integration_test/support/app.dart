import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:patrol/patrol.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/lifecycle/bootstrap_service.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/main.dart' as app;

Future<void> markOnboarded() async {
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString('user_settings');
  final now = DateTime.now().toUtc().toIso8601String();
  final settings = stored == null
      ? <String, Object?>{
          'currencyCode': 'BDT',
          'emailFetchLimit': 100,
          'notificationsEnabled': true,
          'theme': 'system',
          'createdAt': now,
          'updatedAt': now,
        }
      : jsonDecode(stored) as Map<String, Object?>;
  settings['onboardingCompleted'] = true;
  await prefs.setString('user_settings', jsonEncode(settings));
}

Future<void> settle(WidgetTester tester, [double seconds = 2]) async {
  for (var i = 0; i < seconds * 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> startApp(WidgetTester tester, {int seconds = 20}) async {
  final testHandler = FlutterError.onError;
  final testErrorWidget = ErrorWidget.builder;

  if (di.getIt.isRegistered<BootstrapService>()) {
    await di.getIt.unregister<BootstrapService>();
  }
  app.main();
  await settle(tester, seconds.toDouble());
  FlutterError.onError = testHandler;
  ErrorWidget.builder = testErrorWidget;
  LocaleSettings.setLocaleSync(AppLocale.en);
}

Future<void> launchOnboarded(PatrolIntegrationTester $) async {
  await markOnboarded();
  await startApp($.tester);
}

Future<void> openRoute(PatrolIntegrationTester $, String location) async {
  final context = $.tester.element(find.byType(Navigator).first);
  unawaited(GoRouter.of(context).push(location));
  await settle($.tester);
}

Future<void> hideKeyboard(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await settle(tester, 1);
}

Future<void> tapText(PatrolIntegrationTester $, String text) async {
  await hideKeyboard($.tester);
  final target = find.text(text).last;
  await $.tester.ensureVisible(target);
  await settle($.tester, 0.5);
  await $.tester.tap(target);
  await settle($.tester);
}

Future<void> tapLowest(PatrolIntegrationTester $, String text) async {
  await hideKeyboard($.tester);
  double top(Element e) =>
      (e.renderObject! as RenderBox).localToGlobal(Offset.zero).dy;
  final matches = find.text(text).evaluate().toList()
    ..sort((a, b) => top(a).compareTo(top(b)));
  final lowest = matches.last;
  await $.tester.tap(find.byElementPredicate((e) => e == lowest));
  await settle($.tester);
}

Future<void> goBack(PatrolIntegrationTester $) async {
  await $.tester.tap(find.byTooltip(t.common.back).last);
  await settle($.tester);
}

Future<bool> permissionDialogShown(PatrolIntegrationTester $) => $
    .platform
    .mobile
    .isPermissionDialogVisible(timeout: const Duration(seconds: 10));
