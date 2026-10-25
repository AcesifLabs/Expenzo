import 'package:alchemist/alchemist.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../support/all_screens.dart';
import '../support/core_screens.dart';
import '../support/family_bloc_mock.dart';

/// Every golden is drawn on this day, so dates on screen never change.
final _clock = Clock.fixed(DateTime(2026, 10, 15, 10, 30));

/// The core screens, from the screen registry.
const _screens = {
  'Home': 'home',
  'Activity': 'activity',
  'Budgets': 'budgets',
  'Budget details': 'budget_details',
  'Reports': 'reports',
  'Transaction sheet': 'transaction_sheet',
  'Settings / Settings list': 'settings',
  'Family home': 'family_home',
  'Onboarding / income': 'onboarding_income',
  'Sign in': 'sign_in',
};

const _phone = Size(360, 640);

Widget _scenario(
  String name,
  Widget screen, {
  required ThemeData theme,
  required double textScale,
}) {
  return GoldenTestScenario.withTextScaleFactor(
    name: name,
    textScaler: TextScaler.linear(textScale),
    child: Theme(
      data: theme,
      child: SizedBox.fromSize(
        size: _phone,
        child: Scaffold(body: screen),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFamilyEventFallback();
  });
  setUp(registerScreenTestDependencies);
  tearDown(() {
    LocaleSettings.setLocaleSync(AppLocale.en);

    return di.getIt.reset();
  });

  for (final MapEntry(key: name, value: file) in _screens.entries) {
    final screen = allScreens.singleWhere((s) => s.name == name);
    for (final locale in AppLocale.values) {
      goldenTest(
        '$name in ${locale.languageCode}',
        fileName: '${file}_${locale.languageCode}',
        builder: () => withClock(_clock, () {
          LocaleSettings.setLocaleSync(locale);
          // Built once: builders register their dependencies.
          final widget = screen.build();

          return TranslationProvider(
            child: GoldenTestGroup(
              columns: 2,
              children: [
                for (final (themeName, theme) in [
                  ('light', AppTheme.lightTheme),
                  ('dark', AppTheme.darkTheme),
                ])
                  for (final textScale in [1.0, 2.0])
                    _scenario(
                      '$themeName, text ×$textScale',
                      widget,
                      theme: theme,
                      textScale: textScale,
                    ),
              ],
            ),
          );
        }),
        pumpWidget: (tester, widget) =>
            withClock(_clock, () => tester.pumpWidget(widget)),
        // Fixed frames: some screens animate forever.
        pumpBeforeTest: (tester) => withClock(_clock, () async {
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
        }),
      );
    }
  }
}
