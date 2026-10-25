import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/create_budget.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/update_budget.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/delete_budget.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_transactions.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_event.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class MockGetBudgets extends Mock implements GetBudgets {}

class MockCreateBudget extends Mock implements CreateBudget {}

class MockUpdateBudget extends Mock implements UpdateBudget {}

class MockDeleteBudget extends Mock implements DeleteBudget {}

class MockGetBudgetsWithProgress extends Mock
    implements GetBudgetsWithProgress {}

class MockGetBudgetTransactions extends Mock implements GetBudgetTransactions {}

void main() {
  late MockGetBudgets mockGetBudgets;
  late MockCreateBudget mockCreateBudget;
  late MockUpdateBudget mockUpdateBudget;
  late MockDeleteBudget mockDeleteBudget;
  late MockGetBudgetsWithProgress mockGetBudgetsWithProgress;
  late MockGetBudgetTransactions mockGetBudgetTransactions;
  late BudgetBloc bloc;

  final now = DateTime.now();
  final testBudget = Budget(
    id: 'budget-1',
    name: 'Overall Budget',
    amount: 1000,
    period: BudgetPeriod.monthly,
    startDate: DateTime(now.year, now.month, 1),
    isEnabled: true,
  );

  setUp(() {
    mockGetBudgets = MockGetBudgets();
    mockCreateBudget = MockCreateBudget();
    mockUpdateBudget = MockUpdateBudget();
    mockDeleteBudget = MockDeleteBudget();
    mockGetBudgetsWithProgress = MockGetBudgetsWithProgress();
    mockGetBudgetTransactions = MockGetBudgetTransactions();

    bloc = BudgetBloc(
      getBudgets: mockGetBudgets,
      createBudget: mockCreateBudget,
      updateBudget: mockUpdateBudget,
      deleteBudget: mockDeleteBudget,
      getBudgetsWithProgress: mockGetBudgetsWithProgress,
      getBudgetTransactions: mockGetBudgetTransactions,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final progress = BudgetProgress(
    budgetId: 'budget-1',
    name: 'Test Budget',
    budgetAmount: 1000,
    effectiveAmount: 1000,
    spentAmount: 200,
    rolloverAmount: 0,
    percentage: 20,
    isOverBudget: false,
    periodRange: DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    ),
    period: BudgetPeriod.monthly,
  );

  void stubLoad({List<BudgetProgress> progressList = const []}) {
    when(() => mockGetBudgets()).thenAnswer((_) async => Right([testBudget]));
    when(
      () => mockGetBudgetsWithProgress(limit: any(named: 'limit')),
    ).thenAnswer((_) async => Right(progressList));
  }

  group('LoadBudgets', () {
    blocTest<BudgetBloc, BudgetState>(
      'emits loading, then the budgets with their progress',
      setUp: () => stubLoad(progressList: [progress]),
      build: () => bloc,
      act: (bloc) => bloc.add(const LoadBudgets()),
      expect: () => [
        isA<BudgetLoading>(),
        isA<BudgetLoaded>().having(
          (s) => s.progressByBudgetId,
          'progressByBudgetId',
          {'budget-1': progress},
        ),
      ],
    );

    blocTest<BudgetBloc, BudgetState>(
      'emits loading, then the storage message when loading fails',
      setUp: () => when(
        () => mockGetBudgets(),
      ).thenAnswer((_) async => Left(CacheFailure(message: 'Failed to load'))),
      build: () => bloc,
      act: (bloc) => bloc.add(const LoadBudgets()),
      expect: () => [
        isA<BudgetLoading>(),
        isA<BudgetError>().having(
          (s) => s.message,
          'message',
          t.common.errors.storage,
        ),
      ],
    );
  });

  blocTest<BudgetBloc, BudgetState>(
    'loading transactions marks the loaded state busy, then done',
    setUp: () {
      stubLoad(progressList: [progress]);
      when(
        () => mockGetBudgetTransactions('budget-1'),
      ).thenAnswer((_) async => const Right([]));
    },
    build: () => bloc,
    act: (bloc) async {
      bloc.add(const LoadBudgets());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const LoadBudgetTransactions('budget-1'));
    },
    expect: () => [
      isA<BudgetLoading>(),
      isA<BudgetLoaded>(),
      isA<BudgetLoaded>().having(
        (s) => s.isLoadingTransactions,
        'isLoadingTransactions',
        true,
      ),
      isA<BudgetLoaded>().having(
        (s) => s.isLoadingTransactions,
        'isLoadingTransactions',
        false,
      ),
    ],
  );

  blocTest<BudgetBloc, BudgetState>(
    'a double tap on Create creates one budget',
    setUp: () {
      registerFallbackValue(testBudget);
      when(() => mockCreateBudget(any())).thenAnswer((_) async {
        // A real write takes a moment; the second tap lands during it.
        await Future<void>.delayed(const Duration(milliseconds: 20));

        return Right(testBudget);
      });
      stubLoad();
    },
    build: () => bloc,
    act: (bloc) => bloc
      ..add(CreateBudgetEvent(testBudget))
      ..add(CreateBudgetEvent(testBudget)),
    wait: const Duration(milliseconds: 100),
    verify: (_) => verify(() => mockCreateBudget(any())).called(1),
  );
}
