import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_empty_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_page_header.dart';
import '../../../support/pump_localized.dart';

Widget _app(Widget child) =>
    translated(MaterialApp(theme: AppTheme.lightTheme, home: child));

void main() {
  testWidgets('header shows title, subtitle and actions as an app bar', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Scaffold(
          appBar: AppPageHeader(
            title: 'Budgets',
            subtitle: 'Track your monthly limits',
            actions: [TextButton(onPressed: () {}, child: const Text('New'))],
          ),
        ),
      ),
    );

    expect(find.text('Budgets'), findsOneWidget);
    expect(find.text('Track your monthly limits'), findsOneWidget);
    expect(find.text('New'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty state offers its action only when one is given', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: AppEmptyState(
            icon: Icons.inbox,
            message: 'No budgets yet',
            actionLabel: 'New budget',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('New budget'));
    expect(tapped, isTrue);

    await tester.pumpWidget(
      _app(
        const Scaffold(
          body: AppEmptyState(icon: Icons.inbox, message: 'Nothing here'),
        ),
      ),
    );
    expect(find.byType(ElevatedButton), findsNothing);
  });
}
