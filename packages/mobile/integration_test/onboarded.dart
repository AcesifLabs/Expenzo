import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/lifecycle/bootstrap_service.dart';
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
  for (var i = 0; i < seconds * 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  FlutterError.onError = testHandler;
  ErrorWidget.builder = testErrorWidget;
}
