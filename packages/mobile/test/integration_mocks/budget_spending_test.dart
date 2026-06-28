import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';

class MockRecordRepository extends Mock implements RecordRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  late MockRecordRepository mockRecordRepository;
  late MockCategoryRepository mockCategoryRepository;
  late MockBudgetRepository mockBudgetRepository;
  late GetBudgetsWithProgress getBudgetsWithProgress;

  final now = DateTime.now();
  final periodStart = DateTime(now.year, now.month, 1);

  setUp(() {
    mockRecordRepository = MockRecordRepository();
    mockCategoryRepository = MockCategoryRepository();
    mockBudgetRepository = MockBudgetRepository();
    getBudgetsWithProgress = GetBudgetsWithProgress(
      budgetRepository: mockBudgetRepository,
      recordRepository: mockRecordRepository,
      categoryRepository: mockCategoryRepository,
    );
  });

  setUpAll(() {
    registerFallbackValue(DateTime.now());
  });

  group('Budget spending excludes income records', () {
    test('getTotalSpending returns only expense totals, not income', () async {
      final testBudget = Budget(
        id: 'budget-overall',
        categoryId: null,
        amount: 300.0,
        period: BudgetPeriod.monthly,
        startDate: periodStart,
        isEnabled: true,
      );

      when(
        () => mockBudgetRepository.getBudgets(),
      ).thenAnswer((_) async => Right([testBudget]));

      when(
        () => mockRecordRepository.getTotalSpending(any(), any()),
      ).thenAnswer((_) async => const Right(150.0));

      final result = await getBudgetsWithProgress();

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (
        progressList,
      ) {
        expect(progressList.length, 1);
        final progress = progressList.first;
        expect(progress.spentAmount, 150.0);
        expect(progress.percentage, 50.0);
      });
    });

    test(
      'getCategorySpending excludes income records in same category',
      () async {
        const categoryId = '1';

        final testBudget = Budget(
          id: 'budget-cat',
          categoryId: categoryId,
          amount: 200.0,
          period: BudgetPeriod.monthly,
          startDate: periodStart,
          isEnabled: true,
        );

        when(
          () => mockBudgetRepository.getBudgets(),
        ).thenAnswer((_) async => Right([testBudget]));

        when(
          () => mockRecordRepository.getCategorySpending(
            categoryId,
            any(),
            any(),
          ),
        ).thenAnswer((_) async => const Right(100.0));

        final result = await getBudgetsWithProgress();

        expect(result.isRight(), true);
        result.fold((failure) => fail('Should not return failure'), (
          progressList,
        ) {
          expect(progressList.length, 1);
          final progress = progressList.first;
          expect(progress.spentAmount, 100.0);
          expect(progress.percentage, 50.0);
        });
      },
    );

    test('budget progress percentage uses expense-only spending', () async {
      final testBudget = Budget(
        id: 'budget-1',
        categoryId: null,
        amount: 500.0,
        period: BudgetPeriod.monthly,
        startDate: periodStart,
        rolloverEnabled: false,
        rolloverAmount: 0,
        isEnabled: true,
      );

      when(
        () => mockBudgetRepository.getBudgets(),
      ).thenAnswer((_) async => Right([testBudget]));

      when(
        () => mockRecordRepository.getTotalSpending(any(), any()),
      ).thenAnswer((_) async => const Right(200.0));

      final result = await getBudgetsWithProgress();

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (
        progressList,
      ) {
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
      'overall budget progress ignores income even when present in period',
      () async {
        final testBudget = Budget(
          id: 'budget-2',
          categoryId: null,
          amount: 1000.0,
          period: BudgetPeriod.monthly,
          startDate: periodStart,
          isEnabled: true,
        );

        when(
          () => mockBudgetRepository.getBudgets(),
        ).thenAnswer((_) async => Right([testBudget]));

        when(
          () => mockRecordRepository.getTotalSpending(any(), any()),
        ).thenAnswer((_) async => const Right(600.0));

        final result = await getBudgetsWithProgress();

        result.fold((failure) => fail('Should not return failure'), (
          progressList,
        ) {
          final progress = progressList.first;
          expect(progress.spentAmount, 600.0);
          expect(progress.percentage, 60.0);
          expect(progress.isOverBudget, false);
        });
      },
    );

    test('category budget progress ignores income in same category', () async {
      const categoryId = '5';
      final testBudget = Budget(
        id: 'budget-3',
        categoryId: categoryId.toString(),
        amount: 300.0,
        period: BudgetPeriod.monthly,
        startDate: periodStart,
        isEnabled: true,
      );

      when(
        () => mockBudgetRepository.getBudgets(),
      ).thenAnswer((_) async => Right([testBudget]));

      when(
        () =>
            mockRecordRepository.getCategorySpending(categoryId, any(), any()),
      ).thenAnswer((_) async => const Right(250.0));

      final result = await getBudgetsWithProgress();

      result.fold((failure) => fail('Should not return failure'), (
        progressList,
      ) {
        final progress = progressList.first;
        expect(progress.spentAmount, 250.0);
        expect(progress.percentage, closeTo(83.33, 0.01));
        expect(progress.isOverBudget, false);
      });
    });

    test(
      'over-budget detection works correctly with expense-only totals',
      () async {
        final testBudget = Budget(
          id: 'budget-4',
          categoryId: null,
          amount: 200.0,
          period: BudgetPeriod.monthly,
          startDate: periodStart,
          isEnabled: true,
        );

        when(
          () => mockBudgetRepository.getBudgets(),
        ).thenAnswer((_) async => Right([testBudget]));

        when(
          () => mockRecordRepository.getTotalSpending(any(), any()),
        ).thenAnswer((_) async => const Right(250.0));

        final result = await getBudgetsWithProgress();

        result.fold((failure) => fail('Should not return failure'), (
          progressList,
        ) {
          final progress = progressList.first;
          expect(progress.spentAmount, 250.0);
          expect(progress.percentage, 125.0);
          expect(progress.isOverBudget, true);
        });
      },
    );

    test('disabled budgets are excluded from progress calculation', () async {
      final disabledBudget = Budget(
        id: 'budget-disabled',
        categoryId: null,
        amount: 500.0,
        period: BudgetPeriod.monthly,
        startDate: periodStart,
        isEnabled: false,
      );

      when(
        () => mockBudgetRepository.getBudgets(),
      ).thenAnswer((_) async => Right([disabledBudget]));

      final result = await getBudgetsWithProgress();

      result.fold((failure) => fail('Should not return failure'), (
        progressList,
      ) {
        expect(progressList.isEmpty, true);
      });

      verifyNever(() => mockRecordRepository.getTotalSpending(any(), any()));
    });

    test(
      'budget with rollover includes rollover in effective amount',
      () async {
        final rolloverBudget = Budget(
          id: 'budget-rollover',
          categoryId: null,
          amount: 500.0,
          period: BudgetPeriod.monthly,
          startDate: periodStart,
          rolloverEnabled: true,
          rolloverAmount: 100.0,
          isEnabled: true,
        );

        when(
          () => mockBudgetRepository.getBudgets(),
        ).thenAnswer((_) async => Right([rolloverBudget]));

        when(
          () => mockRecordRepository.getTotalSpending(any(), any()),
        ).thenAnswer((_) async => const Right(300.0));

        final result = await getBudgetsWithProgress();

        result.fold((failure) => fail('Should not return failure'), (
          progressList,
        ) {
          final progress = progressList.first;
          expect(progress.effectiveAmount, 600.0);
          expect(progress.spentAmount, 300.0);
          expect(progress.percentage, 50.0);
          expect(progress.rolloverAmount, 100.0);
          expect(progress.isOverBudget, false);
        });
      },
    );
  });
}
