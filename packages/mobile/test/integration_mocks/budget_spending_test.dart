import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';

import '../support/factories/budget_factory.dart';

class MockRecordRepository extends Mock implements RecordRepository {}

class MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  late MockRecordRepository mockRecordRepository;
  late MockBudgetRepository mockBudgetRepository;
  late GetBudgetsWithProgress getBudgetsWithProgress;

  final now = DateTime.now();
  final periodStart = DateTime(now.year, now.month, 1);

  setUp(() {
    mockRecordRepository = MockRecordRepository();
    mockBudgetRepository = MockBudgetRepository();
    getBudgetsWithProgress = GetBudgetsWithProgress(
      budgetRepository: mockBudgetRepository,
      recordRepository: mockRecordRepository,
    );
  });

  setUpAll(() {
    registerFallbackValue(DateTime.now());
  });

  /// Stubs budget-scoped spend keyed by budgetId so different budgets can
  /// report different spend within the same period.
  void stubSpendByBudget(Map<String, double> spendById) {
    when(
      () => mockRecordRepository.getBudgetSpending(any(), any(), any()),
    ).thenAnswer((invocation) async {
      final budgetId = invocation.positionalArguments[0] as String;
      return Right(spendById[budgetId] ?? 0.0);
    });
  }

  group('GetBudgetsWithProgress', () {
    test('computes percentage from the budget-scoped spend', () async {
      final budget = makeBudget(
        id: 'budget-1',
        name: 'Overall Budget',
        amount: 500.0,
        startDate: periodStart,
      );

      when(
        () => mockBudgetRepository.getBudgets(),
      ).thenAnswer((_) async => Right([budget]));
      stubSpendByBudget({'budget-1': 200.0});

      final result = await getBudgetsWithProgress();

      expect(result.isRight(), true);
      result.fold((_) => fail('Should not return failure'), (progressList) {
        expect(progressList.length, 1);
        final progress = progressList.first;
        expect(progress.spentAmount, 200.0);
        expect(progress.percentage, 40.0);
        expect(progress.isOverBudget, false);
        expect(progress.budgetAmount, 500.0);
        expect(progress.effectiveAmount, 500.0);
      });
    });

    test(
      'two budgets in the same period report their own distinct spend',
      () async {
        final food = makeBudget(
          id: 'budget-food',
          name: 'Food',
          amount: 400.0,
          startDate: periodStart,
        );
        final travel = makeBudget(
          id: 'budget-travel',
          name: 'Travel',
          amount: 1000.0,
          startDate: periodStart,
        );

        when(
          () => mockBudgetRepository.getBudgets(),
        ).thenAnswer((_) async => Right([food, travel]));
        stubSpendByBudget({'budget-food': 300.0, 'budget-travel': 100.0});

        final result = await getBudgetsWithProgress();

        result.fold((_) => fail('Should not return failure'), (progressList) {
          final byId = {for (final p in progressList) p.budgetId: p};
          expect(byId['budget-food']!.spentAmount, 300.0);
          expect(byId['budget-food']!.percentage, 75.0);
          expect(byId['budget-travel']!.spentAmount, 100.0);
          expect(byId['budget-travel']!.percentage, 10.0);
        });
      },
    );

    test('over-budget detection works with scoped spend', () async {
      final budget = makeBudget(
        id: 'budget-4',
        amount: 200.0,
        startDate: periodStart,
      );

      when(
        () => mockBudgetRepository.getBudgets(),
      ).thenAnswer((_) async => Right([budget]));
      stubSpendByBudget({'budget-4': 250.0});

      final result = await getBudgetsWithProgress();

      result.fold((_) => fail('Should not return failure'), (progressList) {
        final progress = progressList.first;
        expect(progress.percentage, 125.0);
        expect(progress.isOverBudget, true);
      });
    });

    test('disabled budgets are excluded and not queried', () async {
      final disabled = makeBudget(
        id: 'budget-disabled',
        amount: 500.0,
        startDate: periodStart,
        isEnabled: false,
      );

      when(
        () => mockBudgetRepository.getBudgets(),
      ).thenAnswer((_) async => Right([disabled]));

      final result = await getBudgetsWithProgress();

      result.fold((_) => fail('Should not return failure'), (progressList) {
        expect(progressList.isEmpty, true);
      });

      verifyNever(
        () => mockRecordRepository.getBudgetSpending(any(), any(), any()),
      );
    });

    test('rollover is included in the effective amount', () async {
      final budget = makeBudget(
        id: 'budget-rollover',
        amount: 500.0,
        startDate: periodStart,
        rolloverEnabled: true,
        rolloverAmount: 100.0,
      );

      when(
        () => mockBudgetRepository.getBudgets(),
      ).thenAnswer((_) async => Right([budget]));
      stubSpendByBudget({'budget-rollover': 300.0});

      final result = await getBudgetsWithProgress();

      result.fold((_) => fail('Should not return failure'), (progressList) {
        final progress = progressList.first;
        expect(progress.effectiveAmount, 600.0);
        expect(progress.percentage, 50.0);
        expect(progress.rolloverAmount, 100.0);
        expect(progress.isOverBudget, false);
      });
    });
  });
}
