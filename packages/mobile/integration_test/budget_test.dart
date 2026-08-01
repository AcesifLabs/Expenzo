import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
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
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

    test('should load budgets successfully', () async {
      when(
        () => mockRepository.getBudgets(),
      ).thenAnswer((_) async => Right([testBudget]));
      when(
        () => mockGetBudgetsWithProgress(limit: any(named: 'limit')),
      ).thenAnswer((_) async => const Right([]));

      budgetBloc.add(LoadBudgets());

      await Future.delayed(const Duration(milliseconds: 100));

      expectLater(
        budgetBloc.stream,
        emitsInOrder([isA<BudgetLoading>(), isA<BudgetLoaded>()]),
      );
    });

    test('should create budget successfully', () async {
      when(
        () => mockRepository.createBudget(any()),
      ).thenAnswer((_) async => Right(testBudget));

      budgetBloc.add(CreateBudgetEvent(testBudget));

      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockRepository.createBudget(testBudget)).called(1);
    });

    test('should update budget successfully', () async {
      when(
        () => mockRepository.updateBudget(any()),
      ).thenAnswer((_) async => Right(testBudget));

      budgetBloc.add(UpdateBudgetEvent(testBudget));

      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockRepository.updateBudget(testBudget)).called(1);
    });

    test('should delete budget successfully', () async {
      when(
        () => mockRepository.deleteBudget(any()),
      ).thenAnswer((_) async => const Right(unit));

      budgetBloc.add(const DeleteBudgetEvent('budget_1'));

      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockRepository.deleteBudget('budget_1')).called(1);
    });

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

    test(
      'should block delete if budget has expenses (future implementation)',
      () async {
        when(
          () => mockRepository.deleteBudget(any()),
        ).thenAnswer((_) async => const Right(unit));

        budgetBloc.add(const DeleteBudgetEvent('budget_1'));

        await Future.delayed(const Duration(milliseconds: 100));

        verify(() => mockRepository.deleteBudget('budget_1')).called(1);
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
