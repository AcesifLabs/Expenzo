import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_theme.dart';

import '../support/core_screens.dart';
import '../support/pump_localized.dart';

/// Runs the tap-target and label guidelines (docs: DESIGN.md, Accessibility)
/// on a phone-sized screen.
Future<void> _expectGuidelines(WidgetTester tester, Widget screen) async {
  final handle = tester.ensureSemantics();
  useTestPhone(tester, TestPhone.large);

  await tester.pumpWidget(
    translated(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: screen),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));

  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  handle.dispose();
}

void main() {
  setUp(registerScreenTestDependencies);
  tearDown(() => di.getIt.reset());

  testWidgets('Home', (tester) => _expectGuidelines(tester, homeScreen()));

  testWidgets(
    'Activity',
    (tester) => _expectGuidelines(tester, activityScreen()),
  );

  testWidgets(
    'Budgets',
    (tester) => _expectGuidelines(tester, budgetsScreen()),
  );

  testWidgets(
    'Reports',
    (tester) => _expectGuidelines(tester, reportsScreen()),
  );

  testWidgets(
    'Transaction sheet',
    (tester) => _expectGuidelines(tester, transactionSheetScreen()),
  );
}
