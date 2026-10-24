import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/income_frequency.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:expense_tracker/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:expense_tracker/features/onboarding/presentation/widgets/onboarding_goal_page.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import 'onboarding_test_harness.dart';

void main() {
  setUpAll(registerOnboardingFallbacks);

  Finder field(int i) => find.byType(TextField).at(i);

  testWidgets('Continue needs a name', (tester) async {
    await pumpOnboardingWidget(tester, const OnboardingGoalPage());

    await tester.enterText(field(1), '1999');
    await tester.pump();

    expect(primaryButton(tester).onPressed, isNull);
  });

  testWidgets('a name and an amount submit the goal', (tester) async {
    final bloc = await pumpOnboardingWidget(tester, const OnboardingGoalPage());

    await tester.enterText(field(0), 'Laptop');
    await tester.enterText(field(1), '1,999');
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();

    expect(
      bloc.state.draft.goal,
      const GoalDraft(name: 'Laptop', targetAmount: 1999),
    );
  });

  testWidgets('"No goal for now" declines the goal', (tester) async {
    final bloc = await pumpOnboardingWidget(tester, const OnboardingGoalPage());

    await tester.tap(find.text(t.onboarding.goal.notNow));
    await tester.pumpAndSettle();

    expect(bloc.state.draft.goal, isNull);
    expect(bloc.state.step, 1);
  });

  testWidgets('a goal in the draft prefills both fields', (tester) async {
    await pumpOnboardingWidget(
      tester,
      const OnboardingGoalPage(),
      events: const [
        IncomeSubmitted(5000, IncomeFrequency.monthly),
        GoalSubmitted('Laptop', 1999),
      ],
    );

    expect(find.widgetWithText(TextField, 'Laptop'), findsOneWidget);
    expect(find.widgetWithText(TextField, '1999'), findsOneWidget);
  });
}
