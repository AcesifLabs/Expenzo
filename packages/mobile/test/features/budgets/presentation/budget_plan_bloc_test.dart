import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget_plan_snapshot.dart';
import 'package:expense_tracker/features/budgets/domain/entities/plan_changes.dart';
import 'package:expense_tracker/features/budgets/domain/entities/plan_row.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_plan.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/save_budget_plan.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_plan_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_plan_event.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_plan_state.dart';

import '../../../support/factories/budget_factory.dart';

class _MockGet extends Mock implements GetBudgetPlan {}

class _MockSave extends Mock implements SaveBudgetPlan {}

void main() {
  late _MockGet getPlan;
  late _MockSave savePlan;

  final rent = makeBudget(id: '1', name: 'Rent', amount: 1000);
  final stored = BudgetPlanSnapshot(
    monthlyIncome: 5000,
    recurringTotal: 1200,
    budgets: [rent],
  );
  const rentRow = PlanRow(key: '1', budgetId: '1', name: 'Rent', amount: 1000);
  final editing = BudgetPlanEditing(
    stored: stored,
    income: 5000,
    rows: const [rentRow],
  );
  const failure = CacheFailure(message: 'disk');
  final changes = PlanChanges(
    toCreate: const [],
    toUpdate: [rent],
    toDelete: const [],
  );

  setUpAll(() {
    registerFallbackValue(
      const SaveBudgetPlanParams(
        changes: PlanChanges.empty,
        monthlyIncome: null,
      ),
    );
  });

  setUp(() {
    getPlan = _MockGet();
    savePlan = _MockSave();
    when(() => getPlan()).thenAnswer((_) async => Right(stored));
    when(() => savePlan(any())).thenAnswer((_) async => const Right(unit));
  });

  BudgetPlanBloc build() =>
      BudgetPlanBloc(getBudgetPlan: getPlan, saveBudgetPlan: savePlan);

  blocTest<BudgetPlanBloc, BudgetPlanState>(
    'load turns stored budgets into rows',
    build: build,
    act: (bloc) => bloc.add(const BudgetPlanLoadRequested()),
    expect: () => [const BudgetPlanLoading(), editing],
  );

  test('base is income minus recurring, falling back to stored', () {
    expect(editing.base, 3800);
    expect(editing.copyWith(clearIncome: true).base, 3800);
    expect(
      BudgetPlanEditing(
        stored: BudgetPlanSnapshot(
          monthlyIncome: null,
          recurringTotal: 1200,
          budgets: [rent],
        ),
        income: null,
        rows: const [],
      ).base,
      -1200,
    );
  });

  blocTest<BudgetPlanBloc, BudgetPlanState>(
    'a failed load reports it',
    build: build,
    setUp: () =>
        when(() => getPlan()).thenAnswer((_) async => const Left(failure)),
    act: (bloc) => bloc.add(const BudgetPlanLoadRequested()),
    expect: () => [const BudgetPlanLoading(), isA<BudgetPlanLoadFailed>()],
  );

  blocTest<BudgetPlanBloc, BudgetPlanState>(
    'income and row edits update the state',
    build: build,
    seed: () => editing,
    act: (bloc) => bloc
      ..add(const BudgetPlanIncomeChanged(6000))
      ..add(BudgetPlanRowsChanged([rentRow.copyWith(amount: 900)])),
    expect: () => [
      editing.copyWith(income: 6000),
      editing.copyWith(income: 6000, rows: [rentRow.copyWith(amount: 900)]),
    ],
  );

  blocTest<BudgetPlanBloc, BudgetPlanState>(
    'save sends the stored budgets, rows and income',
    build: build,
    seed: () => editing.copyWith(income: 6000),
    act: (bloc) => bloc.add(BudgetPlanSaveRequested(changes)),
    expect: () => [
      editing.copyWith(income: 6000, status: BudgetPlanSaveStatus.saving),
      editing.copyWith(income: 6000, status: BudgetPlanSaveStatus.saved),
    ],
    verify: (_) => verify(
      () =>
          savePlan(SaveBudgetPlanParams(changes: changes, monthlyIncome: 6000)),
    ).called(1),
  );

  blocTest<BudgetPlanBloc, BudgetPlanState>(
    'a failed save reports it, then reloads what is stored',
    build: build,
    seed: () => editing.copyWith(rows: const []),
    setUp: () => when(
      () => savePlan(any()),
    ).thenAnswer((_) async => const Left(failure)),
    act: (bloc) => bloc.add(BudgetPlanSaveRequested(changes)),
    expect: () => [
      editing.copyWith(rows: const [], status: BudgetPlanSaveStatus.saving),
      editing.copyWith(rows: const [], status: BudgetPlanSaveStatus.failed),
      editing,
    ],
  );

  blocTest<BudgetPlanBloc, BudgetPlanState>(
    'a second save after the first succeeds is ignored',
    build: build,
    seed: () => editing.copyWith(status: BudgetPlanSaveStatus.saved),
    act: (bloc) => bloc.add(BudgetPlanSaveRequested(changes)),
    expect: () => <BudgetPlanState>[],
    verify: (_) => verifyNever(() => savePlan(any())),
  );
}
