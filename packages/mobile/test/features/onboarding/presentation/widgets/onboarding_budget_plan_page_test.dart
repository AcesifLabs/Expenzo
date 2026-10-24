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

  SwitchListTile toggle(WidgetTester tester) =>
      tester.widget<SwitchListTile>(find.byType(SwitchListTile));

  testWidgets('shows the three shares of what is left', (tester) async {
    await pumpOnboardingWidget(
      tester,
      const OnboardingBudgetPlanPage(),
      events: draft(income: 5000, recurring: 1225),
    );

    for (final amount in [1887.5, 1132.5, 755.0]) {
      expect(
        find.textContaining(CurrencyFormatter.format(amount)),
        findsOneWidget,
        reason: '$amount',
      );
    }
    expect(
      find.text(
        t.onboarding.plan.perMonth(amount: CurrencyFormatter.format(3775)),
      ),
      findsOneWidget,
    );
  });

  testWidgets('turning off budgets then Continue submits false', (
    tester,
  ) async {
    final bloc = await pumpOnboardingWidget(
      tester,
      const OnboardingBudgetPlanPage(),
      events: draft(income: 5000, recurring: 1225),
    );

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();

    expect(bloc.state.draft.createBudgets, isFalse);
    expect(bloc.state.step, 3);
  });

  testWidgets('without income it explains and disables the switch', (
    tester,
  ) async {
    await pumpOnboardingWidget(
      tester,
      const OnboardingBudgetPlanPage(),
      events: draft(),
    );

    expect(find.text(t.onboarding.plan.noIncome), findsOneWidget);
    expect(toggle(tester).onChanged, isNull);
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
    expect(toggle(tester).onChanged, isNull);
  });
}
