import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/error/usecase.dart';

import '../support/all_screens.dart';
import '../support/core_screens.dart';
import '../support/family_bloc_mock.dart';
import '../support/pump_localized.dart';

/// With the keyboard open over any field of a form, its submit button can
/// still be scrolled to and tapped.
void main() {
  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFamilyEventFallback();
  });
  setUp(registerScreenTestDependencies);
  tearDown(() => di.getIt.reset());

  /// The field editing [controller]. Found by controller, not position:
  /// a lazy list builds and drops fields as it scrolls.
  Finder fieldWith(TextEditingController controller) => find.byWidgetPredicate(
    (w) => w is EditableText && identical(w.controller, controller),
  );

  for (final screen in allScreens) {
    final submit = screen.submit;
    if (submit == null) continue;

    testWidgets('${screen.name} with the keyboard open', (tester) async {
      useTestPhone(tester, TestPhone.small);
      // 300 logical pixels: a phone keyboard.
      tester.view.viewInsets = const FakeViewPadding(bottom: 600);
      await pumpLocalized(tester, Scaffold(body: screen.build()));
      await tester.pumpAndSettle();
      final scrollable = find.byType(Scrollable).first;

      Future<void> scrollBy(double dy) async {
        await tester.drag(scrollable, Offset(0, dy));
        await tester.pumpAndSettle();
      }

      // Every field, top to bottom.
      final controllers = <TextEditingController>[];
      for (var step = 0; step < 20; step++) {
        for (final element in find.byType(EditableText).evaluate()) {
          final controller = (element.widget as EditableText).controller;
          if (!controllers.contains(controller)) controllers.add(controller);
        }
        if (scrollable.evaluate().isEmpty) break;
        await scrollBy(-150);
      }
      expect(controllers, isNotEmpty, reason: 'a form has fields');

      for (final controller in controllers) {
        final field = fieldWith(controller);
        await scrollBy(3000);
        for (var step = 0; field.evaluate().isEmpty && step < 20; step++) {
          await scrollBy(-100);
        }
        await tester.ensureVisible(field);
        await tester.pumpAndSettle();
        await tester.showKeyboard(field);
        await tester.pumpAndSettle();

        // A lazy list builds the button only once it is scrolled near.
        if (submit().evaluate().isEmpty) {
          await tester.scrollUntilVisible(
            submit(),
            100,
            scrollable: scrollable,
          );
        }
        await expectReachable(tester, submit());
      }
    });
  }
}
