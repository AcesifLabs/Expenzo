import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/income_frequency.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/onboarding_result.dart';
import 'package:expense_tracker/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:expense_tracker/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:expense_tracker/features/onboarding/presentation/widgets/onboarding_timeline_page.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_frequency.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import 'onboarding_test_harness.dart';

void main() {
  setUpAll(registerOnboardingFallbacks);

  const draftEvents = [
    IncomeSubmitted(5000, IncomeFrequency.monthly),
    RecurringItemAdded(
      RecurringDraft(
        description: 'Rent',
        amount: 1225,
        frequency: RecurringFrequency.monthly,
      ),
    ),
    RecurringSubmitted(),
    BudgetPlanSubmitted(true),
    GoalSubmitted('Laptop', 1999),
  ];

  Finder months(int n) => find.text(t.onboarding.timeline.months(n: n));

  Finder mark(String label) =>
      find.byWidgetPredicate((w) => w is Icon && w.semanticLabel == label);

  testWidgets('only "1 month" is marked as more than the savings', (
    tester,
  ) async {
    await pumpOnboardingWidget(
      tester,
      const OnboardingTimelinePage(),
      events: draftEvents,
    );

    expect(mark(t.onboarding.timeline.fit.tooExpensive), findsOneWidget);
    expect(mark(t.onboarding.timeline.fit.slow), findsOneWidget);
    expect(mark(t.onboarding.timeline.fit.affordable), findsNWidgets(2));
  });

  testWidgets('choosing 3 months shows the summary with the goal', (
    tester,
  ) async {
    final bloc = await pumpOnboardingWidget(
      tester,
      const OnboardingTimelinePage(),
      events: draftEvents,
    );

    await tester.tap(months(3));
    await tester.pumpAndSettle();

    expect(bloc.state.draft.goal?.months, 3);
    expect(find.text(t.onboarding.complete.title), findsOneWidget);
    expect(
      find.text(t.onboarding.complete.goal(name: 'Laptop')),
      findsOneWidget,
    );
  });

  testWidgets('a custom date two months ahead shows "2 months"', (
    tester,
  ) async {
    final bloc = await pumpOnboardingWidget(
      tester,
      const OnboardingTimelinePage(),
      events: draftEvents,
    );
    final now = DateTime.now();
    final date = DateTime(now.year, now.month + 2, now.day);

    await tester.tap(find.text(t.onboarding.timeline.custom));
    await tester.pumpAndSettle();

    Navigator.of(tester.element(find.byType(DatePickerDialog))).pop(date);
    await tester.pumpAndSettle();

    expect(bloc.state.draft.goal?.customDate, date);
    expect(
      find.text(
        '${t.onboarding.timeline.custom} · ${t.onboarding.timeline.months(n: 2)}',
      ),
      findsOneWidget,
    );
  });

  testWidgets('cancelling the picker keeps the earlier choice', (tester) async {
    final bloc = await pumpOnboardingWidget(
      tester,
      const OnboardingTimelinePage(),
      events: draftEvents,
    );
    await tester.tap(months(3));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.onboarding.timeline.custom));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(DatePickerDialog))).pop();
    await tester.pumpAndSettle();

    expect(bloc.state.draft.goal?.months, 3);
    expect(bloc.state.draft.goal?.customDate, isNull);
  });

  testWidgets('two taps on Finish save once and show the spinner meanwhile', (
    tester,
  ) async {
    final complete = MockCompleteOnboarding();
    final pending = Completer<Either<Failure, OnboardingResult>>();
    when(() => complete(any())).thenAnswer((_) => pending.future);
    final bloc = await pumpOnboardingWidget(
      tester,
      const OnboardingTimelinePage(),
      complete: complete,
      events: draftEvents,
    );
    await tester.tap(months(3));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.onboarding.complete.finish));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton).last, warnIfMissed: false);
    await tester.pump();

    pending.complete(const Right(OnboardingResult()));
    await tester.pumpAndSettle();
    verify(() => complete(any())).called(1);
    expect(bloc.state.status, OnboardingStatus.done);
  });

  testWidgets('a failure re-enables Finish setup', (tester) async {
    final complete = MockCompleteOnboarding();
    when(
      () => complete(any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'prefs')));
    final bloc = await pumpOnboardingWidget(
      tester,
      const OnboardingTimelinePage(),
      complete: complete,
      events: draftEvents,
    );
    await tester.tap(months(3));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.onboarding.complete.finish));
    await tester.pumpAndSettle();

    expect(bloc.state.status, OnboardingStatus.failure);
    expect(primaryButton(tester).onPressed, isNotNull);
  });
}
