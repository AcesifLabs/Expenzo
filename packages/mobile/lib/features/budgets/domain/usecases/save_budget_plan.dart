import 'package:clock/clock.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';

import '../entities/plan_changes.dart';
import '../repositories/budget_repository.dart';

class SaveBudgetPlanParams extends Equatable {
  final PlanChanges changes;
  final double? monthlyIncome;

  @override
  List<Object?> get props => [changes, monthlyIncome];

  const SaveBudgetPlanParams({
    required this.changes,
    required this.monthlyIncome,
  });
}

/// Writes the plan's budget changes in one go, then the income. Income is
/// saved only when it was given and changed: a blank field keeps the
/// stored income.
class SaveBudgetPlan {
  final BudgetRepository budgetRepository;
  final SettingsRepository settingsRepository;

  SaveBudgetPlan({
    required this.budgetRepository,
    required this.settingsRepository,
  });

  Future<Either<Failure, Unit>> call(SaveBudgetPlanParams params) async {
    final changes = params.changes;
    if (!changes.isEmpty) {
      final saved = await budgetRepository.applyPlanChanges(changes);
      if (saved case Left(:final value)) return Left(value);
    }

    return _saveIncome(params.monthlyIncome);
  }

  Future<Either<Failure, Unit>> _saveIncome(double? income) async {
    if (income == null) return const Right(unit);
    final loaded = await settingsRepository.getSettings();

    return loaded.fold(Left.new, (settings) async {
      if (settings.monthlyIncome == income) return const Right(unit);
      final saved = await settingsRepository.updateSettings(
        settings.copyWith(
          monthlyIncome: income,
          updatedAt: clock.now().toUtc(),
        ),
      );

      return saved.map((_) => unit);
    });
  }
}
