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
  final periodEnd = DateTime(now.year, now.month + 1, 1);

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

  // These tests verify the use-case layer contract with stubbed repositories.
  // For DAO-level income/expense filtering verification, see integration tests
  // that use an in-memory Drift database with real record insertion.
  group('Budget spending excludes income records', () {
    test(
      'getTotalSpending returns only expense totals, not income',
      () async {
        // Arrange: Overall budget, stub returns expense-only spending
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

        // Act
        final result = await getBudgetsWithProgress();

        // Assert: Spending visible in budget progress
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (progressList) {
            expect(progressList.length, 1);
            final progress = progressList.first;
            expect(progress.spentAmount, 150.0);
            expect(progress.percentage, 50.0); // 150/300 * 100
          },
        );
      },
    );

    test(
      'getCategorySpending excludes income records in same category',
      () async {
        const categoryId = '1';

        // Arrange: Category budget, stub returns expense-only spending
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
            int.parse(categoryId),
            any(),
            any(),
          ),
        ).thenAnswer((_) async => const Right(100.0));

        // Act
        final result = await getBudgetsWithProgress();

        // Assert: Only expense spending counted in budget progress
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (progressList) {
            expect(progressList.length, 1);
            final progress = progressList.first;
            expect(progress.spentAmount, 100.0);
            expect(progress.percentage, 50.0); // 100/200 * 100
          },
        );
      },
    );

    test(
      'budget progress percentage uses expense-only spending',
      () async {
        // Arrange: Budget of $500, with $200 in expenses
        final testBudget = Budget(
          id: 'budget-1',
          categoryId: null, // Overall budget
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

        // Act
        final result = await getBudgetsWithProgress();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (progressList) {
            expect(progressList.length, 1);

            final progress = progressList.first;
            expect(progress.spentAmount, 200.0);
            expect(progress.percentage, 40.0); // 200 / 500 * 100
            expect(progress.isOverBudget, false);
            expect(progress.budgetAmount, 500.0);
            expect(progress.effectiveAmount, 500.0);
          },
        );
      },
    );

    test(
      'overall budget progress ignores income even when present in period',
      () async {
        // Arrange: Budget of $1000, expenses total $600, income total $400
        // Progress should show 60% (600/1000), NOT 20% ((600-400)/1000)
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

        // getTotalSpending only returns expense total (600), income excluded by DAO filter
        when(
          () => mockRecordRepository.getTotalSpending(any(), any()),
        ).thenAnswer((_) async => const Right(600.0));

        // Act
        final result = await getBudgetsWithProgress();

        // Assert
        result.fold(
          (failure) => fail('Should not return failure'),
          (progressList) {
            final progress = progressList.first;
            expect(progress.spentAmount, 600.0);
            expect(progress.percentage, 60.0); // 600/1000 * 100
            expect(progress.isOverBudget, false);
          },
        );
      },
    );

    test(
      'category budget progress ignores income in same category',
      () async {
        // Arrange: Category budget of $300, expenses in category = $250,
        // income in category = $100 (should be ignored)
        const categoryId = 5;
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

        // getCategorySpending returns only expense total for category 5
        when(
          () => mockRecordRepository.getCategorySpending(
            categoryId,
            any(),
            any(),
          ),
        ).thenAnswer((_) async => const Right(250.0));

        // Act
        final result = await getBudgetsWithProgress();

        // Assert
        result.fold(
          (failure) => fail('Should not return failure'),
          (progressList) {
            final progress = progressList.first;
            expect(progress.spentAmount, 250.0);
            expect(
              progress.percentage,
              closeTo(83.33, 0.01),
            ); // 250/300 * 100
            expect(progress.isOverBudget, false);
          },
        );
      },
    );

    test(
      'over-budget detection works correctly with expense-only totals',
      () async {
        // Arrange: Budget of $200, expenses = $250 (over budget)
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

        // Act
        final result = await getBudgetsWithProgress();

        // Assert
        result.fold(
          (failure) => fail('Should not return failure'),
          (progressList) {
            final progress = progressList.first;
            expect(progress.spentAmount, 250.0);
            expect(progress.percentage, 125.0); // 250/200 * 100
            expect(progress.isOverBudget, true);
          },
        );
      },
    );

    test(
      'disabled budgets are excluded from progress calculation',
      () async {
        final disabledBudget = Budget(
          id: 'budget-disabled',
          categoryId: null,
          amount: 500.0,
          period: BudgetPeriod.monthly,
          startDate: periodStart,
          isEnabled: false, // Disabled
        );

        when(
          () => mockBudgetRepository.getBudgets(),
        ).thenAnswer((_) async => Right([disabledBudget]));

        // Act
        final result = await getBudgetsWithProgress();

        // Assert: No progress entries for disabled budgets
        result.fold(
          (failure) => fail('Should not return failure'),
          (progressList) {
            expect(progressList.isEmpty, true);
          },
        );

        // Verify getTotalSpending was never called (budget skipped)
        verifyNever(
          () => mockRecordRepository.getTotalSpending(any(), any()),
        );
      },
    );

    test(
      'budget with rollover includes rollover in effective amount',
      () async {
        // Arrange: Budget $500 + $100 rollover = $600 effective
        // Expenses = $300 → 50% utilization
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

        // Act
        final result = await getBudgetsWithProgress();

        // Assert
        result.fold(
          (failure) => fail('Should not return failure'),
          (progressList) {
            final progress = progressList.first;
            expect(progress.effectiveAmount, 600.0); // 500 + 100
            expect(progress.spentAmount, 300.0);
            expect(progress.percentage, 50.0); // 300/600 * 100
            expect(progress.rolloverAmount, 100.0);
            expect(progress.isOverBudget, false);
          },
        );
      },
    );
  });
}
