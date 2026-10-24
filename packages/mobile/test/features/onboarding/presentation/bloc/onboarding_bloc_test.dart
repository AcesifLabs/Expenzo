import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/income_frequency.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/onboarding_result.dart';
import 'package:expense_tracker/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:expense_tracker/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:expense_tracker/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:expense_tracker/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_frequency.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';

class _MockComplete extends Mock implements CompleteOnboarding {}

class _MockGetSettings extends Mock implements GetSettings {}

void main() {
  late _MockComplete complete;
  late _MockGetSettings getSettings;
  late OnboardingBloc bloc;
  const result = OnboardingResult(recurringCount: 1);
  const rent = RecurringDraft(
    description: 'Rent',
    amount: 1200,
    frequency: RecurringFrequency.monthly,
  );

  setUpAll(() {
    registerFallbackValue(const OnboardingDraft());
    registerFallbackValue(NoParams());
  });

  setUp(() {
    complete = _MockComplete();
    getSettings = _MockGetSettings();
    when(() => complete(any())).thenAnswer((_) async => const Right(result));
    bloc = OnboardingBloc(
      completeOnboarding: complete,
      getSettings: getSettings,
    );
  });

  tearDown(() => bloc.close());

  Future<OnboardingState> after(List<OnboardingEvent> events) async {
    for (final event in events) {
      bloc.add(event);
    }
    await pumpEventQueue();

    return bloc.state;
  }

  UserSettings storedIncome(double income) => UserSettings(
    currencyCode: 'BDT',
    emailFetchLimit: 100,
    notificationsEnabled: true,
    theme: 'system',
    monthlyIncome: income,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  test('start fills the draft with the saved income (Replay setup)', () async {
    when(
      () => getSettings(any()),
    ).thenAnswer((_) async => Right(storedIncome(3000)));

    final state = await after([const OnboardingStarted()]);

    expect(state.draft.monthlyIncome, 3000);
    expect(state.step, 0);
  });

  test('an income typed before settings load is kept', () async {
    final settings = Completer<Either<Failure, UserSettings>>();
    when(() => getSettings(any())).thenAnswer((_) => settings.future);

    await after([
      const OnboardingStarted(),
      const IncomeSubmitted(5000, IncomeFrequency.monthly),
    ]);
    settings.complete(Right(storedIncome(3000)));
    await pumpEventQueue();

    expect(bloc.state.draft.monthlyIncome, 5000);
  });

  test('weekly income is stored per month and moves to step 1', () async {
    final state = await after([
      const IncomeSubmitted(1000, IncomeFrequency.weekly),
    ]);

    expect((state.draft.monthlyIncome! * 100).round() / 100, 4333.33);
    expect(state.step, 1);
  });

  test('adding two items and removing one leaves one in the draft', () async {
    final state = await after([
      const IncomeSubmitted(5000, IncomeFrequency.monthly),
      const RecurringItemAdded(rent),
      const RecurringItemAdded(
        RecurringDraft(
          description: 'Gym',
          amount: 30,
          frequency: RecurringFrequency.monthly,
        ),
      ),
      const RecurringItemRemoved(1),
      const RecurringSubmitted(),
    ]);

    expect(state.draft.recurring, [rent]);
    expect(state.step, 2);
  });

  test('back from step 2 returns to step 1 and keeps the draft', () async {
    final before = await after([
      const IncomeSubmitted(5000, IncomeFrequency.monthly),
      const RecurringItemAdded(rent),
      const RecurringSubmitted(),
    ]);

    final back = await after([const OnboardingStepBack()]);

    expect(back.step, 1);
    expect(back.draft, before.draft);
  });

  test('back on step 0 emits nothing', () async {
    final states = <OnboardingState>[];
    final sub = bloc.stream.listen(states.add);

    await after([const OnboardingStepBack()]);
    await sub.cancel();

    expect(states, isEmpty);
  });

  test('skip after income saves just the income', () async {
    await after([
      const IncomeSubmitted(5000, IncomeFrequency.monthly),
      const OnboardingSkipped(),
    ]);

    final draft =
        verify(() => complete(captureAny())).captured.single as OnboardingDraft;
    expect(draft, const OnboardingDraft(monthlyIncome: 5000));
  });

  test('finish emits saving then done with the result', () async {
    final expectation = expectLater(
      bloc.stream.map((s) => s.status),
      emitsInOrder([OnboardingStatus.saving, OnboardingStatus.done]),
    );

    bloc.add(const OnboardingFinished());

    await expectation;
    expect(bloc.state.result, result);
  });

  test('two quick finishes save once', () async {
    final pending = Completer<Either<Failure, OnboardingResult>>();
    when(() => complete(any())).thenAnswer((_) => pending.future);

    bloc
      ..add(const OnboardingFinished())
      ..add(const OnboardingFinished())
      ..add(const OnboardingSkipped());
    await pumpEventQueue();
    pending.complete(const Right(result));
    await pumpEventQueue();

    verify(() => complete(any())).called(1);
  });

  test('a failure keeps the step and shows the error', () async {
    when(
      () => complete(any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'prefs')));

    final state = await after([
      const IncomeSubmitted(5000, IncomeFrequency.monthly),
      const OnboardingFinished(),
    ]);

    expect(state.status, OnboardingStatus.failure);
    expect(state.errorText, isNotEmpty);
    expect(state.step, 1);
  });

  test('declining the goal clears it and moves to the last step', () async {
    final state = await after([
      const IncomeSubmitted(5000, IncomeFrequency.monthly),
      const RecurringSubmitted(),
      const BudgetPlanSubmitted(true),
      const GoalSubmitted('Laptop', 1999),
      const OnboardingStepBack(),
      const GoalDeclined(),
    ]);

    expect(state.draft.goal, isNull);
    expect(state.step, 4);
  });
}
