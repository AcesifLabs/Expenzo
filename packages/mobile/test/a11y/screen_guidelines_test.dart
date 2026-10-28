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
import '../support/pump_localized.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFamilyEventFallback();
  });
  setUp(registerScreenTestDependencies);
  tearDown(() => di.getIt.reset());

  final themes = {'light': AppTheme.lightTheme, 'dark': AppTheme.darkTheme};

  for (final screen in allScreens) {
    for (final MapEntry(key: themeName, value: theme) in themes.entries) {
      for (final locale in AppLocale.values) {
        testWidgets('${screen.name}, $themeName, ${locale.languageCode}', (
          tester,
        ) async {
          final handle = tester.ensureSemantics();
          useTestPhone(tester, TestPhone.large);
          await pumpLocalized(
            tester,
            Scaffold(body: screen.build()),
            locale: locale,
            theme: theme,
          );
          await tester.pump(const Duration(milliseconds: 500));

          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          handle.dispose();
        });
      }
    }
  }
}
