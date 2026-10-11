import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budgets/presentation/helpers/budget_summary.dart';
import 'package:expense_tracker/features/budgets/presentation/widgets/budget_progress_card.dart';
import '../../support/pump_localized.dart';

BudgetProgress _progress({required double spent, double limit = 500}) {
  return BudgetProgress(
    budgetId: 'b1',
    budgetAmount: limit,
    effectiveAmount: limit,
    spentAmount: spent,
    rolloverAmount: 0,
    percentage: spent / limit * 100,
    isOverBudget: spent > limit,
    name: 'Food',
    // Half-open: October 1st up to (not including) November 1st.
    periodRange: DateTimeRange(
      start: DateTime(2026, 10),
      end: DateTime(2026, 11),
    ),
    period: BudgetPeriod.monthly,
  );
}

void main() {
  setUp(() => CurrencyFormatter.current.value = CurrencyConfig.byCode('BDT'));

  group('BudgetSummary', () {
    test('remaining money and days left in the period', () {
      final summary = BudgetSummary.of(
        _progress(spent: 120),
        now: DateTime(2026, 10, 11, 15),
      );

      expect(summary.remaining, 380);
      expect(summary.isOver, isFalse);
      expect(summary.daysLeft, 21);
      expect(summary.daysLeftLabel, '21 days left');
    });

    test('the last day of the period says so', () {
      final summary = BudgetSummary.of(
        _progress(spent: 0),
        now: DateTime(2026, 10, 31, 23),
      );

      expect(summary.daysLeftLabel, 'Last day');
    });

    test('over the limit is negative remaining', () {
      final summary = BudgetSummary.of(
        _progress(spent: 520),
        now: DateTime(2026, 10, 11),
      );

      expect(summary.isOver, isTrue);
      expect(summary.remaining, -20);
    });
  });

  group('BudgetProgressCard', () {
    Future<void> pumpCard(WidgetTester tester, BudgetProgress progress) {
      return tester.pumpWidget(
        translated(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: BudgetProgressCard(
                progress: progress,
                onTap: () {},
                onEdit: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );
    }

    Color barColor(WidgetTester tester) =>
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .color ??
        Colors.transparent;

    testWidgets('under budget leads with what is left', (tester) async {
      await pumpCard(tester, _progress(spent: 120));

      expect(find.text('৳380 left'), findsOneWidget);
      expect(find.text('৳120 of ৳500 spent'), findsOneWidget);
      expect(barColor(tester), AppPalette.light.income);
    });

    testWidgets('80% turns the bar amber', (tester) async {
      await pumpCard(tester, _progress(spent: 400));

      expect(find.text('৳100 left'), findsOneWidget);
      expect(barColor(tester), AppPalette.light.warning);
    });

    testWidgets('over budget says by how much, in rose', (tester) async {
      await pumpCard(tester, _progress(spent: 520));

      final headline = tester.widget<Text>(find.text('Over by ৳20'));
      expect(headline.style?.color, AppPalette.light.expense);
      expect(barColor(tester), AppPalette.light.expense);
    });
  });
}
