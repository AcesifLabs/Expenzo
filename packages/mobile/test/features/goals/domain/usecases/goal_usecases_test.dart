import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/goals/domain/goals_domain.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class _MockGoalRepository extends Mock implements GoalRepository {}

void main() {
  late _MockGoalRepository repository;
  const goal = Goal(
    id: 'g-1',
    name: 'Laptop',
    targetAmount: 1999,
    savedAmount: 100,
  );

  setUpAll(() => registerFallbackValue(goal));

  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
    repository = _MockGoalRepository();
    when(
      () => repository.createGoal(any()),
    ).thenAnswer((i) async => Right(i.positionalArguments.first as Goal));
    when(
      () => repository.updateGoal(any()),
    ).thenAnswer((i) async => Right(i.positionalArguments.first as Goal));
    when(
      () => repository.getGoalById('g-1'),
    ).thenAnswer((_) async => const Right(goal));
  });

  String? textOf(Either<Failure, Object?> result) =>
      result.fold((f) => failureText(f), (_) => null);

  test('CreateGoal with a blank name fails and never saves', () async {
    final result = await CreateGoal(repository: repository)(
      goal.copyWith(name: '  '),
    );

    expect(textOf(result), t.goals.errors.nameRequired);
    verifyNever(() => repository.createGoal(any()));
  });

  test('CreateGoal with a valid goal saves it', () async {
    final result = await CreateGoal(repository: repository)(goal);

    expect(result, const Right<Failure, Goal>(goal));
    verify(() => repository.createGoal(goal)).called(1);
  });

  test('CreateGoal rejects a target above the maximum', () async {
    final result = await CreateGoal(repository: repository)(
      goal.copyWith(targetAmount: 10000000000),
    );

    expect(textOf(result), t.goals.errors.amountTooLarge);
  });

  test('AddGoalContribution raises savedAmount through updateGoal', () async {
    final result = await AddGoalContribution(repository: repository)(
      const AddGoalContributionParams(goalId: 'g-1', amount: 50),
    );

    expect(result.fold((_) => null, (g) => g.savedAmount), 150);
    verify(
      () => repository.updateGoal(goal.copyWith(savedAmount: 150)),
    ).called(1);
  });

  test('AddGoalContribution refuses 0', () async {
    final result = await AddGoalContribution(repository: repository)(
      const AddGoalContributionParams(goalId: 'g-1', amount: 0),
    );

    expect(textOf(result), t.goals.errors.amountPositive);
    verifyNever(() => repository.updateGoal(any()));
  });

  test('AddGoalContribution refuses a total above the maximum', () async {
    final result = await AddGoalContribution(repository: repository)(
      const AddGoalContributionParams(goalId: 'g-1', amount: 9999999999.99),
    );

    expect(textOf(result), t.goals.errors.amountTooLarge);
    verifyNever(() => repository.updateGoal(any()));
  });

  test(
    'AddGoalContribution for a missing goal returns the repository failure',
    () async {
      const missing = CacheFailure(
        message: 'no goal',
        errorCode: FailureCodes.notFound,
      );
      when(
        () => repository.getGoalById('gone'),
      ).thenAnswer((_) async => const Left(missing));

      final result = await AddGoalContribution(repository: repository)(
        const AddGoalContributionParams(goalId: 'gone', amount: 10),
      );

      expect(result, const Left<Failure, Goal>(missing));
    },
  );

  test('DeleteGoal forwards the id', () async {
    when(
      () => repository.deleteGoal('g-1'),
    ).thenAnswer((_) async => const Right(unit));

    await DeleteGoal(repository: repository)('g-1');

    verify(() => repository.deleteGoal('g-1')).called(1);
  });
}
