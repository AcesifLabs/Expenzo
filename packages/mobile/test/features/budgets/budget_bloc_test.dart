import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// TODO: Migrate to blocTest<BudgetBloc, BudgetState>(...) when bloc_test dep
// can be added (currently blocked by version conflicts). Example:
//   blocTest<BudgetBloc, BudgetState>(
//     'emits [BudgetLoading, BudgetLoaded]',
//     build: () => bloc,
//     act: (bloc) => bloc.add(LoadBudgets()),
//     expect: () => [isA<BudgetLoading>(), isA<BudgetLoaded>()],
//   );

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
    categoryId: null,
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

  group('LoadBudgets', () {
    test(
      'emits [BudgetLoading, BudgetLoaded] with progress when both succeed',
      () async {
        final progress = BudgetProgress(
          budgetId: 'budget-1',
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

        when(
          () => mockGetBudgets(),
        ).thenAnswer((_) async => Right([testBudget]));
        when(
          () => mockGetBudgetsWithProgress(limit: any(named: 'limit')),
        ).thenAnswer((_) async => Right([progress]));

        final expected = [
          isA<BudgetLoading>(),
          isA<BudgetLoaded>().having(
            (s) => s.progressByBudgetId,
            'progressByBudgetId',
            {'budget-1': progress},
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(LoadBudgets());
      },
    );

    test('emits [BudgetLoading, BudgetError] when GetBudgets fails', () async {
      when(
        () => mockGetBudgets(),
      ).thenAnswer((_) async => Left(ServerFailure(message: 'Failed to load')));

      final expected = [
        isA<BudgetLoading>(),
        isA<BudgetError>().having(
          (s) => s.message,
          'message',
          'Failed to load',
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(LoadBudgets());
    });
  });

  group('LoadBudgetTransactions', () {
    test('emits loading then transactions on the loaded state', () async {
      final progress = BudgetProgress(
        budgetId: 'budget-1',
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

      when(() => mockGetBudgets()).thenAnswer((_) async => Right([testBudget]));
      when(
        () => mockGetBudgetsWithProgress(limit: any(named: 'limit')),
      ).thenAnswer((_) async => Right([progress]));
      when(
        () => mockGetBudgetTransactions('budget-1'),
      ).thenAnswer((_) async => const Right([]));

      expectLater(
        bloc.stream,
        emitsInOrder([
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
        ]),
      );

      bloc.add(LoadBudgets());

      await Future.delayed(Duration.zero);
      bloc.add(const LoadBudgetTransactions('budget-1'));
    });
  });
}
