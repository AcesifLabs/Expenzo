import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';

import '../../support/factories/budget_factory.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  late MockBudgetRepository repository;
  late GetBudgetProgress useCase;

  setUp(() {
    repository = MockBudgetRepository();
    useCase = GetBudgetProgress(repository: repository);
  });

  test('computes percentage and isOverBudget from spend', () async {
    when(
      () => repository.getBudgetById('b1'),
    ).thenAnswer((_) async => Right(makeBudget(id: 'b1', amount: 500)));

    final result = await useCase(budgetId: 'b1', spentAmount: 250);

    result.fold((_) => fail('expected success'), (p) {
      expect(p.percentage, 50.0);
      expect(p.effectiveAmount, 500.0);
      expect(p.isOverBudget, false);
    });
  });

  test('includes rollover in the effective amount', () async {
    when(() => repository.getBudgetById('b1')).thenAnswer(
      (_) async => Right(
        makeBudget(
          id: 'b1',
          amount: 500,
          rolloverEnabled: true,
          rolloverAmount: 100,
        ),
      ),
    );

    final result = await useCase(budgetId: 'b1', spentAmount: 550);

    result.fold((_) => fail('expected success'), (p) {
      expect(p.effectiveAmount, 600.0);
      expect(p.isOverBudget, false);
      expect(p.percentage, closeTo(91.67, 0.01));
    });
  });

  test(
    'isOverBudget is false when spend equals effective (strict >)',
    () async {
      when(
        () => repository.getBudgetById('b1'),
      ).thenAnswer((_) async => Right(makeBudget(id: 'b1', amount: 300)));

      final result = await useCase(budgetId: 'b1', spentAmount: 300);

      result.fold((_) => fail('expected success'), (p) {
        expect(p.isOverBudget, false);
      });
    },
  );

  test('guards against zero effective budget (no divide by zero)', () async {
    when(() => repository.getBudgetById('b1')).thenAnswer(
      (_) async =>
          Right(makeBudget(id: 'b1', amount: 0, rolloverEnabled: false)),
    );

    final result = await useCase(budgetId: 'b1', spentAmount: 10);

    result.fold((_) => fail('expected success'), (p) {
      expect(p.percentage, 0.0);
      expect(p.percentage.isNaN, false);
      expect(p.percentage.isInfinite, false);
    });
  });

  test('returns Left when the budget lookup fails', () async {
    when(
      () => repository.getBudgetById('b1'),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'not found')));

    final result = await useCase(budgetId: 'b1', spentAmount: 10);

    expect(result.isLeft(), true);
  });
}
