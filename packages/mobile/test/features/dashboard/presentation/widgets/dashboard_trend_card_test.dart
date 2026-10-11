import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_trend_card.dart';
import 'package:expense_tracker/features/reports/domain/entities/date_amount.dart';
import '../../../../support/pump_localized.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester, {
    double? percentChange,
    List<DateAmount> trend = const [],
  }) async {
    await tester.pumpWidget(
      translated(
        MaterialApp(
          home: Scaffold(
            body: DashboardTrendCard(
              title: 'This month',
              totalSpent: 122,
              percentChange: percentChange,
              previousPeriodLabel: 'last month',
              trend: trend,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('says there is nothing to compare when last month is empty', (
    tester,
  ) async {
    await pumpCard(tester);

    expect(find.text('No spending last month to compare'), findsOneWidget);
    expect(find.textContaining('No change'), findsNothing);
  });

  testWidgets('shows the percent change against last month', (tester) async {
    await pumpCard(tester, percentChange: 25);

    expect(find.text('+25% vs last month'), findsOneWidget);
  });

  testWidgets('a single spending day does not fill the chart width', (
    tester,
  ) async {
    await pumpCard(
      tester,
      trend: [
        for (var day = 1; day <= 10; day++)
          DateAmount(date: DateTime(2026, 10, day), amount: day == 4 ? 122 : 0),
      ],
    );

    final bars = tester.widgetList<Container>(
      find.descendant(
        of: find.byType(DashboardTrendCard),
        matching: find.byWidgetPredicate(
          (w) => w is Container && w.constraints?.maxWidth == 16,
        ),
      ),
    );
    expect(bars, hasLength(10));
  });
}
