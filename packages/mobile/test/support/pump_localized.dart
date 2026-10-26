import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'connectivity_test_support.dart';

Widget translated(Widget app) {
  LocaleSettings.setLocaleSync(AppLocale.en);

  return TranslationProvider(child: app);
}

Widget localizedApp({
  required Widget home,
  AppLocale locale = AppLocale.en,
  ThemeData? theme,
}) {
  LocaleSettings.setLocaleSync(locale);

  return TranslationProvider(
    child: MaterialApp(
      locale: locale.flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: theme,
      home: home,
    ),
  );
}

Future<void> pumpLocalized(
  WidgetTester tester,
  Widget home, {
  AppLocale locale = AppLocale.en,
  ThemeData? theme,
  Widget Function(Widget app)? wrap,
}) async {
  registerTestConnectivity();
  final app = localizedApp(home: home, locale: locale, theme: theme);

  await tester.pumpWidget(wrap == null ? app : wrap(app));

  await tester.pump();
}
