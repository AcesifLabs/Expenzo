import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget.dart';
import 'package:expense_tracker/features/budgets/domain/entities/plan_changes.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/save_budget_plan.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';

import '../../../../support/factories/budget_factory.dart';
import '../../../../support/factories/user_settings_factory.dart';

class _MockBudgets extends Mock implements BudgetRepository {}

class _MockSettings extends Mock implements SettingsRepository {}

void main() {
  late _MockBudgets budgets;
  late _MockSettings settings;
  late SaveBudgetPlan save;

  final stored = makeUserSettings().copyWith(monthlyIncome: 5000);
  final changes = PlanChanges(
    toCreate: [
      Budget(
        name: 'Travel',
        amount: 200,
        period: BudgetPeriod.monthly,
        startDate: DateTime(2026, 10),
      ),
    ],
    toUpdate: [makeBudget(id: '2', name: 'Food', amount: 450)],
    toDelete: [makeBudget(id: '3', name: 'Gone')],
  );
  const failure = CacheFailure(message: 'disk');

  setUpAll(() {
    registerFallbackValue(PlanChanges.empty);
    registerFallbackValue(stored);
  });

  setUp(() {
    budgets = _MockBudgets();
    settings = _MockSettings();
    save = SaveBudgetPlan(
      budgetRepository: budgets,
      settingsRepository: settings,
    );
    when(
      () => budgets.applyPlanChanges(any()),
    ).thenAnswer((_) async => const Right(unit));
    when(() => settings.getSettings()).thenAnswer((_) async => Right(stored));
    when(() => settings.updateSettings(any())).thenAnswer(
      (i) async => Right(i.positionalArguments.first as UserSettings),
    );
  });

  Future<Either<Failure, Unit>> run({
    PlanChanges? planChanges,
    double? income = 5000,
  }) => save(
    SaveBudgetPlanParams(
      changes: planChanges ?? changes,
      monthlyIncome: income,
    ),
  );

  test('applies the budget changes in one call', () async {
    expect(await run(), const Right<Failure, Unit>(unit));

    verify(() => budgets.applyPlanChanges(changes)).called(1);
    verifyNever(() => settings.updateSettings(any()));
  });

  test('no budget changes skips the budget write', () async {
    await run(planChanges: PlanChanges.empty);

    verifyNever(() => budgets.applyPlanChanges(any()));
  });

  test('a failed budget write returns it and leaves income alone', () async {
    when(
      () => budgets.applyPlanChanges(any()),
    ).thenAnswer((_) async => const Left(failure));

    expect(await run(income: 6000), const Left<Failure, Unit>(failure));
    verifyNever(() => settings.updateSettings(any()));
  });

  test('saves a changed income', () async {
    await run(income: 6000);

    final saved =
        verify(() => settings.updateSettings(captureAny())).captured.single
            as UserSettings;
    expect(saved.monthlyIncome, 6000);
  });

  test('a blank income keeps the stored one', () async {
    expect(await run(income: null), const Right<Failure, Unit>(unit));

    verifyNever(() => settings.getSettings());
    verifyNever(() => settings.updateSettings(any()));
  });

  test('a failed settings read returns Left', () async {
    when(
      () => settings.getSettings(),
    ).thenAnswer((_) async => const Left(failure));

    expect(await run(income: 6000), const Left<Failure, Unit>(failure));
    verify(() => budgets.applyPlanChanges(changes)).called(1);
  });

  test('a failed settings write returns Left', () async {
    when(
      () => settings.updateSettings(any()),
    ).thenAnswer((_) async => const Left(failure));

    expect(await run(income: 6000), const Left<Failure, Unit>(failure));
  });
}
