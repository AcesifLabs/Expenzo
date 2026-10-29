import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:expense_tracker/features/recurring/domain/helpers/monthly_equivalent.dart';
import 'package:expense_tracker/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';

import '../entities/budget.dart';
import '../entities/budget_plan_snapshot.dart';
import '../repositories/budget_repository.dart';

/// Loads the Budget Plan: monthly income, recurring bills per month, and
/// every enabled, personal, monthly budget.
class GetBudgetPlan {
  final BudgetRepository budgetRepository;
  final RecurringRepository recurringRepository;
  final SettingsRepository settingsRepository;

  GetBudgetPlan({
    required this.budgetRepository,
    required this.recurringRepository,
    required this.settingsRepository,
  });

  Future<Either<Failure, BudgetPlanSnapshot>> call() async {
    final (settings, budgets, recurring) = await (
      settingsRepository.getSettings(),
      budgetRepository.getBudgets(),
      recurringRepository.getRecurringList(),
    ).wait;

    return settings.fold<Either<Failure, BudgetPlanSnapshot>>(
      Left.new,
      (settings) => budgets.flatMap(
        (budgets) => recurring.map(
          (recurring) => BudgetPlanSnapshot(
            monthlyIncome: settings.monthlyIncome,
            recurringTotal: _monthlyTotal(recurring),
            budgets: budgets.where(_inPlan).toList()
              ..sort((a, b) => a.name.compareTo(b.name)),
          ),
        ),
      ),
    );
  }

  double _monthlyTotal(List<RecurringTransaction> items) => items
      .where((item) => item.isActive)
      .fold(
        0,
        (sum, item) => sum + monthlyEquivalent(item.amount, item.frequency),
      );

  bool _inPlan(Budget budget) =>
      budget.period == BudgetPeriod.monthly &&
      !budget.isShared &&
      budget.isEnabled;
}
