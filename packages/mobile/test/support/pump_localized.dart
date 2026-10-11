import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Puts the app's translations above an existing [app] (a `MaterialApp` or
/// `MaterialApp.router`) so widgets can read `context.t`. English only; use
/// [localizedApp] to render another locale.
Widget translated(Widget app) {
  LocaleSettings.setLocaleSync(AppLocale.en);

  return TranslationProvider(child: app);
}

/// A [MaterialApp] with the app's translations, for widget tests.
///
/// Also switches the global `t` so non-widget code under test matches.
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

/// Pumps [home] inside [localizedApp]. [wrap] puts providers above the app.
Future<void> pumpLocalized(
  WidgetTester tester,
  Widget home, {
  AppLocale locale = AppLocale.en,
  ThemeData? theme,
  Widget Function(Widget app)? wrap,
}) {
  final app = localizedApp(home: home, locale: locale, theme: theme);

  return tester.pumpWidget(wrap == null ? app : wrap(app));
}
