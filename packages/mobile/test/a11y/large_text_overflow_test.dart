import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/i18n/strings.g.dart';

import '../support/all_screens.dart';
import '../support/core_screens.dart';
import '../support/family_bloc_mock.dart';

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

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFamilyEventFallback();
  });

  for (final screen in allScreens) {
    for (final phone in TestPhone.values) {
      testWidgets(
        '${screen.name} on a ${phone.name} screen',
        (tester) => pumpAtMaxScale(tester, screen.build(), phone: phone),
      );
    }
    testWidgets(
      '${screen.name} in Bangla on a small phone',
      (tester) => pumpAtMaxScale(
        tester,
        screen.build(),
        phone: TestPhone.small,
        locale: AppLocale.bn,
      ),
    );
  }

  for (final phone in TestPhone.values) {
    testWidgets('Reports tabs on a ${phone.name} screen', (tester) async {
      await pumpAtMaxScale(tester, reportsScreen(), phone: phone);

      for (final tab in ['Categories', 'Insights']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        expectLayoutFits(tester);
      }
    });
  }
}
