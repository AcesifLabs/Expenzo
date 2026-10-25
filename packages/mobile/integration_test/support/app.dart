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

/// Marks onboarding done before `app.main()`, so a test that is not about
/// onboarding starts on Home (SAAP-74 redirects a fresh install).
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

/// Pumps fixed frames for [seconds]: the app has endless animations, so
/// `pumpAndSettle` would time out.
Future<void> settle(WidgetTester tester, [double seconds = 2]) async {
  for (var i = 0; i < seconds * 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Starts the app and waits for start-up. `app.main()` replaces
/// [FlutterError.onError] and [ErrorWidget.builder] with the app's own;
/// putting the test's back lets a failed `expect` report normally and keeps
/// the binding's end-of-test check happy.
Future<void> startApp(WidgetTester tester, {int seconds = 20}) async {
  final testHandler = FlutterError.onError;
  final testErrorWidget = ErrorWidget.builder;
  // A second start in the same test run is a relaunch: main() registers
  // BootstrapService itself; the rest of DI is idempotent.
  if (di.getIt.isRegistered<BootstrapService>()) {
    await di.getIt.unregister<BootstrapService>();
  }
  app.main();
  await settle(tester, seconds.toDouble());
  FlutterError.onError = testHandler;
  ErrorWidget.builder = testErrorWidget;
  LocaleSettings.setLocaleSync(AppLocale.en);
}

/// Starts an onboarded app on Home.
Future<void> launchOnboarded(PatrolIntegrationTester $) async {
  await markOnboarded();
  await startApp($.tester);
}

/// Opens [location] through the app's router, as a tap on its row would.
Future<void> openRoute(PatrolIntegrationTester $, String location) async {
  final context = $.tester.element(find.byType(Navigator).first);
  unawaited(GoRouter.of(context).push(location));
  await settle($.tester);
}

/// Closes the soft keyboard: on a device it covers the bottom of the
/// screen, and a tap there would miss.
Future<void> hideKeyboard(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await settle(tester, 1);
}

/// Taps [text] (the last match: dialogs sit above pages).
Future<void> tapText(PatrolIntegrationTester $, String text) async {
  await hideKeyboard($.tester);
  final target = find.text(text).last;
  await $.tester.ensureVisible(target);
  await settle($.tester, 0.5);
  await $.tester.tap(target);
  await settle($.tester);
}

/// Taps the lowest [text] on screen: a page's submit button often repeats
/// its title ("Add budget").
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

/// The app's own back button (AppBackButton), which `pageBack` doesn't know.
Future<void> goBack(PatrolIntegrationTester $) async {
  await $.tester.tap(find.byTooltip(t.common.back).last);
  await settle($.tester);
}

/// Waits for Android's permission dialog; false if none came.
Future<bool> permissionDialogShown(PatrolIntegrationTester $) => $
    .platform
    .mobile
    .isPermissionDialogVisible(timeout: const Duration(seconds: 10));
