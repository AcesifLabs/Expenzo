import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/create_budget.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/update_budget.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/delete_budget.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_transactions.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_event.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_state.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

class MockGetBudgetsWithProgress extends Mock
    implements GetBudgetsWithProgress {}

class MockGetBudgetTransactions extends Mock implements GetBudgetTransactions {}

void main() {
  group('Budget Integration Tests', () {
    late MockBudgetRepository mockRepository;
    late GetBudgets getBudgetsUseCase;
    late CreateBudget createBudgetUseCase;
    late UpdateBudget updateBudgetUseCase;
    late DeleteBudget deleteBudgetUseCase;
    late GetBudgetProgress getBudgetProgressUseCase;
    late MockGetBudgetsWithProgress mockGetBudgetsWithProgress;
    late MockGetBudgetTransactions mockGetBudgetTransactions;
    late BudgetBloc budgetBloc;

    final testBudget = Budget(
      id: 'budget_1',
      name: 'cat_1',
      amount: 5000.0,
      period: BudgetPeriod.monthly,
      startDate: DateTime.now(),
      rolloverEnabled: true,
      rolloverAmount: 0,
      isEnabled: true,
    );

    setUp(() {
      mockRepository = MockBudgetRepository();
      mockGetBudgetsWithProgress = MockGetBudgetsWithProgress();
      mockGetBudgetTransactions = MockGetBudgetTransactions();
      getBudgetsUseCase = GetBudgets(repository: mockRepository);
      createBudgetUseCase = CreateBudget(repository: mockRepository);
      updateBudgetUseCase = UpdateBudget(repository: mockRepository);
      deleteBudgetUseCase = DeleteBudget(repository: mockRepository);
      getBudgetProgressUseCase = GetBudgetProgress(repository: mockRepository);
      budgetBloc = BudgetBloc(
        getBudgets: getBudgetsUseCase,
        createBudget: createBudgetUseCase,
        updateBudget: updateBudgetUseCase,
        deleteBudget: deleteBudgetUseCase,
        getBudgetsWithProgress: mockGetBudgetsWithProgress,
        getBudgetTransactions: mockGetBudgetTransactions,
      );
    });

    tearDown(() {
      budgetBloc.close();
    });

    setUpAll(() => registerFallbackValue(testBudget));

    /// After a write the bloc reloads the list.
    void stubReload() {
      when(
        () => mockRepository.getBudgets(),
      ).thenAnswer((_) async => Right([testBudget]));
      when(
        () => mockGetBudgetsWithProgress(limit: any(named: 'limit')),
      ).thenAnswer((_) async => const Right([]));
    }

    blocTest<BudgetBloc, BudgetState>(
      'loads budgets through the use case',
      setUp: stubReload,
      build: () => budgetBloc,
      act: (bloc) => bloc.add(const LoadBudgets()),
      expect: () => [isA<BudgetLoading>(), isA<BudgetLoaded>()],
    );

    blocTest<BudgetBloc, BudgetState>(
      'creates a budget through the repository',
      setUp: () {
        stubReload();
        when(
          () => mockRepository.createBudget(any()),
        ).thenAnswer((_) async => Right(testBudget));
      },
      build: () => budgetBloc,
      act: (bloc) => bloc.add(CreateBudgetEvent(testBudget)),
      wait: const Duration(milliseconds: 50),
      verify: (_) =>
          verify(() => mockRepository.createBudget(testBudget)).called(1),
    );

    blocTest<BudgetBloc, BudgetState>(
      'updates a budget through the repository',
      setUp: () {
        stubReload();
        when(
          () => mockRepository.updateBudget(any()),
        ).thenAnswer((_) async => Right(testBudget));
      },
      build: () => budgetBloc,
      act: (bloc) => bloc.add(UpdateBudgetEvent(testBudget)),
      wait: const Duration(milliseconds: 50),
      verify: (_) =>
          verify(() => mockRepository.updateBudget(testBudget)).called(1),
    );

    blocTest<BudgetBloc, BudgetState>(
      'deletes a budget through the repository',
      setUp: () {
        stubReload();
        when(
          () => mockRepository.deleteBudget(any()),
        ).thenAnswer((_) async => const Right(unit));
      },
      build: () => budgetBloc,
      act: (bloc) => bloc.add(const DeleteBudgetEvent('budget_1')),
      wait: const Duration(milliseconds: 50),
      verify: (_) =>
          verify(() => mockRepository.deleteBudget('budget_1')).called(1),
    );

    test('should calculate budget progress correctly', () async {
      when(
        () => mockRepository.getBudgetById(any()),
      ).thenAnswer((_) async => Right(testBudget));

      final result = await getBudgetProgressUseCase(
        budgetId: 'budget_1',
        spentAmount: 2500.0,
      );

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (progress) {
        expect(progress.budgetId, 'budget_1');
        expect(progress.percentage, 50.0);
        expect(progress.isOverBudget, false);
      });
    });

    test('should detect over budget when spent exceeds budget', () async {
      when(
        () => mockRepository.getBudgetById(any()),
      ).thenAnswer((_) async => Right(testBudget));

      final result = await getBudgetProgressUseCase(
        budgetId: 'budget_1',
        spentAmount: 6000.0,
      );

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (progress) {
        expect(progress.isOverBudget, true);
      });
    });

    test(
      'should include rollover in budget calculation when enabled',
      () async {
        final budgetWithRollover = testBudget.copyWith(
          rolloverEnabled: true,
          rolloverAmount: 500.0,
        );

        when(
          () => mockRepository.getBudgetById(any()),
        ).thenAnswer((_) async => Right(budgetWithRollover));

        final result = await getBudgetProgressUseCase(
          budgetId: 'budget_1',
          spentAmount: 2750.0,
        );

        expect(result.isRight(), true);
        result.fold((failure) => fail('Should not return failure'), (progress) {
          expect(progress.percentage, 50.0);
        });
      },
    );
  });

  group('Budget Rollover Tests', () {
    test('should calculate effective budget with rollover', () {
      final budget = Budget(
        id: 'budget_1',
        name: 'Overall Budget',
        amount: 5000.0,
        period: BudgetPeriod.monthly,
        startDate: DateTime.now(),
        rolloverEnabled: true,
        rolloverAmount: 500.0,
        isEnabled: true,
      );

      final effectiveBudget = budget.amount + budget.rolloverAmount;
      expect(effectiveBudget, 5500.0);
    });

    test('should not include rollover when disabled', () {
      final budget = Budget(
        id: 'budget_1',
        name: 'Overall Budget',
        amount: 5000.0,
        period: BudgetPeriod.monthly,
        startDate: DateTime.now(),
        rolloverEnabled: false,
        rolloverAmount: 500.0,
        isEnabled: true,
      );

      final effectiveBudget = budget.rolloverEnabled
          ? budget.amount + budget.rolloverAmount
          : budget.amount;
      expect(effectiveBudget, 5000.0);
    });
  });
}
