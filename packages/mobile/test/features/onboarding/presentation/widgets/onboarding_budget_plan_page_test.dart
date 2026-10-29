import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/income_frequency.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:expense_tracker/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:expense_tracker/features/onboarding/presentation/widgets/onboarding_budget_plan_page.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_frequency.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import 'onboarding_test_harness.dart';

void main() {
  setUpAll(registerOnboardingFallbacks);

  List<OnboardingEvent> draft({double? income, double recurring = 0}) => [
    if (income != null) IncomeSubmitted(income, IncomeFrequency.monthly),
    if (recurring > 0)
      RecurringItemAdded(
        RecurringDraft(
          description: 'Rent',
          amount: recurring,
          frequency: RecurringFrequency.monthly,
        ),
      ),
    const RecurringSubmitted(),
  ];

  Finder field(String text) => find.widgetWithText(TextField, text);

  Future<void> tapContinue(WidgetTester tester) async {
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();
  }

  testWidgets('suggests the three shares of what is left', (tester) async {
    await pumpOnboardingWidget(
      tester,
      const OnboardingBudgetPlanPage(),
      events: draft(income: 5000, recurring: 1225),
    );

    for (final text in ['Needs', 'Wants', 'Savings', '1887.50', '1132.50']) {
      expect(field(text), findsOneWidget, reason: text);
    }
    expect(
      find.text(
        t.budgets.plan.perMonth(amount: CurrencyFormatter.format(3775)),
      ),
      findsOneWidget,
    );
  });

  testWidgets('edits reach the draft on Continue', (tester) async {
    final bloc = await pumpOnboardingWidget(
      tester,
      const OnboardingBudgetPlanPage(),
      events: draft(income: 5000, recurring: 1225),
    );

    await tester.enterText(field('Wants'), 'Fun');
    await tester.pump();
    await tester.tap(find.byTooltip('Remove Needs'));
    await tester.pumpAndSettle();
    await tapContinue(tester);

    final rows = bloc.state.draft.budgetRows;
    expect(rows?.map((r) => r.name), ['Fun', 'Savings']);
    expect(rows?.last.isSavings, isTrue);
    expect(bloc.state.step, 3);
  });

  testWidgets('untouched rows follow an income changed after Continue', (
    tester,
  ) async {
    final bloc = await pumpOnboardingWidget(
      tester,
      const OnboardingBudgetPlanPage(),
      events: draft(income: 5000),
    );

    await tapContinue(tester);
    bloc.add(const IncomeSubmitted(6000, IncomeFrequency.monthly));
    await tester.pumpAndSettle();

    expect(field('3000'), findsOneWidget);
    await tapContinue(tester);
    expect(bloc.state.draft.budgetRows?.map((r) => r.amount), [
      3000,
      1800,
      1200,
    ]);
  });

  testWidgets('edited rows survive an income change', (tester) async {
    final bloc = await pumpOnboardingWidget(
      tester,
      const OnboardingBudgetPlanPage(),
      events: draft(income: 5000),
    );

    await tester.enterText(field('2500'), '2000');
    await tester.pump();
    bloc.add(const IncomeSubmitted(6000, IncomeFrequency.monthly));
    await tester.pumpAndSettle();

    expect(field('2000'), findsOneWidget);
    expect(field('3000'), findsNothing);
  });

  testWidgets('a duplicate name blocks Continue', (tester) async {
    final bloc = await pumpOnboardingWidget(
      tester,
      const OnboardingBudgetPlanPage(),
      events: draft(income: 5000),
    );

    await tester.enterText(field('Wants'), 'needs');
    await tester.pump();
    await tapContinue(tester);

    expect(find.text(t.budgets.plan.nameDuplicate), findsNWidgets(2));
    expect(bloc.state.draft.budgetRows, isNull);
    expect(bloc.state.step, 2);
  });

  testWidgets('Skip submits no budgets', (tester) async {
    final bloc = await pumpOnboardingWidget(
      tester,
      const OnboardingBudgetPlanPage(),
      events: draft(income: 5000),
    );

    await tester.ensureVisible(find.text(t.onboarding.plan.skip));
    await tester.tap(find.text(t.onboarding.plan.skip));
    await tester.pumpAndSettle();

    expect(bloc.state.draft.budgetRows, isEmpty);
    expect(bloc.state.step, 3);
  });

  testWidgets('without income it explains and leaves rows at 0', (
    tester,
  ) async {
    final bloc = await pumpOnboardingWidget(
      tester,
      const OnboardingBudgetPlanPage(),
      events: draft(),
    );

    expect(find.text(t.onboarding.plan.noIncome), findsOneWidget);
    await tapContinue(tester);

    expect(bloc.state.draft.budgetRows?.map((r) => r.amount), [0, 0, 0]);
  });

  testWidgets('recurring using all income shows the no-room note', (
    tester,
  ) async {
    await pumpOnboardingWidget(
      tester,
      const OnboardingBudgetPlanPage(),
      events: draft(income: 1000, recurring: 1000),
    );

    expect(find.text(t.onboarding.plan.noRoom), findsOneWidget);
  });
}
