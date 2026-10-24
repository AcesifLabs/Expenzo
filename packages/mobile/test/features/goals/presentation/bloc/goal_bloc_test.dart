import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/goals/domain/goals_domain.dart';
import 'package:expense_tracker/features/goals/presentation/goals_presentation.dart';

class _MockWatch extends Mock implements WatchActiveGoal {}

class _MockAdd extends Mock implements AddGoalContribution {}

void main() {
  late StreamController<Goal?> goals;
  late _MockAdd add;
  late GoalBloc bloc;
  const goal = Goal(
    id: 'g-1',
    name: 'Laptop',
    targetAmount: 1999,
    savedAmount: 100,
  );

  setUpAll(
    () => registerFallbackValue(
      const AddGoalContributionParams(goalId: 'x', amount: 1),
    ),
  );

  setUp(() {
    goals = StreamController<Goal?>();
    final watch = _MockWatch();
    when(() => watch()).thenAnswer((_) => goals.stream);
    add = _MockAdd();
    when(() => add(any())).thenAnswer((_) async => const Right(goal));
    bloc = GoalBloc(watchActiveGoal: watch, addGoalContribution: add)
      ..add(const GoalWatchStarted());
  });

  tearDown(() async {
    await bloc.close();
    await goals.close();
  });

  Future<GoalState> settle() async {
    await pumpEventQueue();

    return bloc.state;
  }

  test('emits ready with the goal from the stream', () async {
    goals.add(goal);

    final state = await settle();

    expect(state.status, GoalStatus.ready);
    expect(state.goal, goal);
  });

  test('a null from the stream means no goal', () async {
    goals.add(goal);
    await settle();
    goals.add(null);

    expect((await settle()).goal, isNull);
  });

  test('a stream error is an error state', () async {
    goals.addError(Exception('db'));

    expect((await settle()).status, GoalStatus.error);
  });

  test('a contribution saves and counts', () async {
    goals.add(goal);
    await settle();
    final statuses = <GoalStatus>[];
    final sub = bloc.stream.listen((s) => statuses.add(s.status));

    bloc.add(const GoalContributionSubmitted(50));
    final state = await settle();
    await sub.cancel();

    expect(statuses, [GoalStatus.saving, GoalStatus.ready]);
    verify(
      () => add(const AddGoalContributionParams(goalId: 'g-1', amount: 50)),
    ).called(1);
    expect(state.lastAdded, 50);
    expect(state.contributionCount, 1);
  });

  test('a second submit while saving is dropped', () async {
    final pending = Completer<Either<Failure, Goal>>();
    when(() => add(any())).thenAnswer((_) => pending.future);
    goals.add(goal);
    await settle();

    bloc
      ..add(const GoalContributionSubmitted(50))
      ..add(const GoalContributionSubmitted(50));
    await settle();
    pending.complete(const Right(goal));
    await settle();

    verify(() => add(any())).called(1);
  });

  test('a failure sets the error text', () async {
    when(
      () => add(any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'disk')));
    goals.add(goal);
    await settle();

    bloc.add(const GoalContributionSubmitted(50));
    final state = await settle();

    expect(state.status, GoalStatus.ready);
    expect(state.errorText, isNotEmpty);
  });
}
