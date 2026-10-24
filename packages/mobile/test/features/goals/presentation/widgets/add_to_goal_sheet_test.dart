import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/goals/presentation/widgets/add_to_goal_sheet.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../../../support/pump_localized.dart';

void main() {
  /// Opens the sheet; returns a getter for what it popped with.
  Future<double? Function()> openSheet(WidgetTester tester) async {
    double? result;
    await pumpLocalized(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                result = await showAddToGoalSheet(context, goalName: 'Laptop'),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    return () => result;
  }

  Future<void> submit(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextFormField), text);
    await tester.tap(find.text(t.common.add));
    await tester.pumpAndSettle();
  }

  testWidgets('empty and 0 ask for an amount above zero', (tester) async {
    final result = await openSheet(tester);

    await submit(tester, '');
    expect(find.text(t.goals.errors.amountPositive), findsOneWidget);
    await submit(tester, '0');
    expect(find.text(t.goals.errors.amountPositive), findsOneWidget);
    expect(result(), isNull);
  });

  testWidgets('too large shows the maximum', (tester) async {
    await openSheet(tester);

    await submit(tester, '10000000000');

    expect(find.text(t.goals.errors.amountTooLarge), findsOneWidget);
  });

  testWidgets('Bangla digits are accepted', (tester) async {
    final result = await openSheet(tester);

    await submit(tester, '১০০');

    expect(result(), 100);
  });
}
