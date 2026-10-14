import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/i18n/strings.g.dart';

import '../support/core_screens.dart';
import '../support/settings_screens.dart';

/// Every main screen at the largest text the app allows
/// (`AppConstants.maxTextScale`): no overflow and no clipped text (SAAP-66).
void main() {
  setUp(registerScreenTestDependencies);
  tearDown(() => di.getIt.reset());

  group('clip check', () {
    Future<List<String>> clippedIn(WidgetTester tester, Widget child) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Center(child: child)),
        ),
      );

      return clippedTexts(tester);
    }

    testWidgets('finds text cut off by a fixed-height box', (tester) async {
      final clipped = await clippedIn(
        tester,
        const SizedBox(width: 200, height: 20, child: Text('Clipped')),
      );

      expect(clipped.single, contains('Clipped'));
    });

    testWidgets('accepts one-line text that ends in an ellipsis', (
      tester,
    ) async {
      final clipped = await clippedIn(
        tester,
        const SizedBox(
          width: 60,
          child: Text(
            'A long label that cannot fit',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );

      expect(clipped, isEmpty);
    });
  });

  for (final phone in TestPhone.values) {
    testWidgets(
      'Home on a ${phone.name} phone',
      (tester) => pumpAtMaxScale(tester, homeScreen(), phone: phone),
    );

    testWidgets(
      'Activity on a ${phone.name} phone',
      (tester) => pumpAtMaxScale(tester, activityScreen(), phone: phone),
    );
  }

  for (final phone in TestPhone.values) {
    testWidgets(
      'Budgets list on a ${phone.name} phone',
      (tester) => pumpAtMaxScale(tester, budgetsScreen(), phone: phone),
    );

    testWidgets(
      'Budgets details on a ${phone.name} phone',
      (tester) => pumpAtMaxScale(tester, budgetDetailsScreen(), phone: phone),
    );

    testWidgets('Budgets form on a ${phone.name} phone', (tester) async {
      await pumpAtMaxScale(tester, budgetFormScreen(), phone: phone);

      await expectReachable(tester, find.text('Save'));
    });
  }

  testWidgets(
    'Budgets list in Bangla',
    (tester) => pumpAtMaxScale(tester, budgetsScreen(), locale: AppLocale.bn),
  );

  for (final phone in TestPhone.values) {
    testWidgets('Reports tabs on a ${phone.name} phone', (tester) async {
      await pumpAtMaxScale(tester, reportsScreen(), phone: phone);

      for (final tab in ['Categories', 'Insights']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        expectLayoutFits(tester);
      }
    });

    testWidgets('Transaction sheet on a ${phone.name} phone', (tester) async {
      await pumpAtMaxScale(tester, transactionSheetScreen(), phone: phone);

      await expectReachable(tester, find.text('Add expense'));
    });

    testWidgets(
      'Bottom navigation on a ${phone.name} phone',
      (tester) => pumpAtMaxScale(tester, appShellScreen(), phone: phone),
    );
  }

  testWidgets(
    'Reports in Bangla',
    (tester) => pumpAtMaxScale(tester, reportsScreen(), locale: AppLocale.bn),
  );

  testWidgets(
    'Transaction sheet in Bangla',
    (tester) =>
        pumpAtMaxScale(tester, transactionSheetScreen(), locale: AppLocale.bn),
  );

  testWidgets(
    'Bottom navigation in Bangla',
    (tester) => pumpAtMaxScale(tester, appShellScreen(), locale: AppLocale.bn),
  );

  testWidgets(
    'Home in Bangla',
    (tester) => pumpAtMaxScale(tester, homeScreen(), locale: AppLocale.bn),
  );

  group('Settings', () {
    setUpAll(() => registerFallbackValue(NoParams()));

    for (final MapEntry(key: name, value: screen) in settingsScreens.entries) {
      for (final locale in [AppLocale.en, AppLocale.bn]) {
        testWidgets(
          'Settings / $name in ${locale.languageCode} on a small phone',
          (tester) => pumpAtMaxScale(
            tester,
            screen(),
            phone: TestPhone.small,
            locale: locale,
          ),
        );
      }
    }
  });
}
