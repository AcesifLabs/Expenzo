import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/goals/domain/goals_domain.dart';
import 'package:expense_tracker/features/goals/presentation/goals_presentation.dart';

class _MockRepository extends Mock implements GoalRepository {}

class _MockCreate extends Mock implements CreateGoal {}

class _MockUpdate extends Mock implements UpdateGoal {}

class _MockDelete extends Mock implements DeleteGoal {}

void main() {
  late _MockRepository repository;
  late _MockCreate create;
  late _MockUpdate update;
  late _MockDelete delete;
  late GoalFormBloc bloc;
  const goal = Goal(id: 'g-1', name: 'Laptop', targetAmount: 1999);

  setUpAll(() => registerFallbackValue(goal));

  setUp(() {
    repository = _MockRepository();
    create = _MockCreate();
    update = _MockUpdate();
    delete = _MockDelete();
    when(
      () => repository.getGoalById('g-1'),
    ).thenAnswer((_) async => const Right(goal));
    when(
      () => update(any()),
    ).thenAnswer((i) async => Right(i.positionalArguments.first as Goal));
    when(
      () => create(any()),
    ).thenAnswer((i) async => Right(i.positionalArguments.first as Goal));
    when(() => delete('g-1')).thenAnswer((_) async => const Right(unit));
    bloc = GoalFormBloc(
      repository: repository,
      createGoal: create,
      updateGoal: update,
      deleteGoal: delete,
    );
  });

  tearDown(() => bloc.close());

  Future<GoalFormState> after(List<GoalFormEvent> events) async {
    for (final e in events) {
      bloc.add(e);
    }
    await pumpEventQueue();

    return bloc.state;
  }

  test('load shows the goal', () async {
    final state = await after([const GoalFormLoaded('g-1')]);

    expect(
      state,
      const GoalFormState(goal: goal, status: GoalFormStatus.ready),
    );
  });

  test('a missing goal is notFound', () async {
    when(() => repository.getGoalById('gone')).thenAnswer(
      (_) async => const Left(
        CacheFailure(message: 'x', errorCode: FailureCodes.notFound),
      ),
    );

    expect(
      (await after([const GoalFormLoaded('gone')])).status,
      GoalFormStatus.notFound,
    );
  });

  test(
    'save calls UpdateGoal and ends saved; a second save while saving is dropped',
    () async {
      final pending = Completer<Either<Failure, Goal>>();
      when(() => update(any())).thenAnswer((_) => pending.future);
      await after([const GoalFormLoaded('g-1')]);
      final statuses = <GoalFormStatus>[];
      final sub = bloc.stream.listen((s) => statuses.add(s.status));

      bloc
        ..add(GoalFormSaved(goal.copyWith(name: 'Phone')))
        ..add(GoalFormSaved(goal.copyWith(name: 'Phone')));
      await pumpEventQueue();
      pending.complete(Right(goal.copyWith(name: 'Phone')));
      await pumpEventQueue();
      await sub.cancel();

      verify(() => update(any())).called(1);
      expect(statuses, [GoalFormStatus.saving, GoalFormStatus.saved]);
    },
  );

  test('delete calls DeleteGoal with the id', () async {
    final state = await after([
      const GoalFormLoaded('g-1'),
      const GoalFormDeleted(),
    ]);

    verify(() => delete('g-1')).called(1);
    expect(state.status, GoalFormStatus.deleted);
  });

  test('create mode starts empty and creates', () async {
    final started = await after([const GoalFormStartedNew()]);
    expect(started, const GoalFormState(status: GoalFormStatus.ready));

    final state = await after([
      const GoalFormCreated(Goal(name: 'Trip', targetAmount: 500)),
    ]);

    verify(() => create(const Goal(name: 'Trip', targetAmount: 500))).called(1);
    expect(state.status, GoalFormStatus.created);
  });
}
