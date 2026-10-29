import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget_plan_snapshot.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_plan.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:expense_tracker/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';

import '../../../../support/factories/budget_factory.dart';
import '../../../../support/factories/recurring_factory.dart';
import '../../../../support/factories/user_settings_factory.dart';

class _MockBudgets extends Mock implements BudgetRepository {}

class _MockRecurring extends Mock implements RecurringRepository {}

class _MockSettings extends Mock implements SettingsRepository {}

void main() {
  late _MockBudgets budgets;
  late _MockRecurring recurring;
  late _MockSettings settings;
  late GetBudgetPlan getPlan;

  final rent = makeBudget(id: '1', name: 'Rent');
  final food = makeBudget(id: '2', name: 'Food');

  setUp(() {
    budgets = _MockBudgets();
    recurring = _MockRecurring();
    settings = _MockSettings();
    getPlan = GetBudgetPlan(
      budgetRepository: budgets,
      recurringRepository: recurring,
      settingsRepository: settings,
    );
    when(() => settings.getSettings()).thenAnswer(
      (_) async => Right(makeUserSettings().copyWith(monthlyIncome: 5000)),
    );
    when(() => budgets.getBudgets()).thenAnswer((_) async => Right([rent]));
    when(
      () => recurring.getRecurringList(),
    ).thenAnswer((_) async => const Right([]));
  });

  test(
    'keeps only enabled, personal, monthly budgets, sorted by name',
    () async {
      when(() => budgets.getBudgets()).thenAnswer(
        (_) async => Right([
          rent,
          makeBudget(id: '3', name: 'Weekly', period: BudgetPeriod.weekly),
          makeBudget(id: '4', name: 'Shared', groupId: 'g1'),
          makeBudget(id: '5', name: 'Off', isEnabled: false),
          food,
        ]),
      );

      final result = await getPlan();

      expect(
        result,
        Right<Failure, BudgetPlanSnapshot>(
          BudgetPlanSnapshot(
            monthlyIncome: 5000,
            recurringTotal: 0,
            budgets: [food, rent],
          ),
        ),
      );
    },
  );

  test('recurring total counts active items per month', () async {
    when(() => recurring.getRecurringList()).thenAnswer(
      (_) async => Right([
        makeRecurring(id: 'a', amount: 1200),
        makeRecurring(
          id: 'b',
          amount: 120,
          frequency: RecurringFrequency.yearly,
        ),
        makeRecurring(id: 'c', amount: 999, isActive: false),
      ]),
    );

    final plan = (await getPlan()).getOrElse(() => throw StateError('left'));

    expect(plan.recurringTotal, 1210);
    expect(plan.base, 3790);
  });

  test('no income gives a negative-or-zero base', () async {
    when(
      () => settings.getSettings(),
    ).thenAnswer((_) async => Right(makeUserSettings()));

    final plan = (await getPlan()).getOrElse(() => throw StateError('left'));

    expect(plan.monthlyIncome, isNull);
    expect(plan.base, 0);
  });

  test('passes any repository failure through', () async {
    const failure = CacheFailure(message: 'boom');
    when(
      () => recurring.getRecurringList(),
    ).thenAnswer((_) async => const Left(failure));

    expect(await getPlan(), const Left<Failure, BudgetPlanSnapshot>(failure));
  });
}
