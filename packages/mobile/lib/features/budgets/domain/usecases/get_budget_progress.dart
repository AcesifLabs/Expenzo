import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/utils/budget_period_utils.dart';
import '../entities/budget_progress.dart';
import '../repositories/budget_repository.dart';

export '../entities/budget_progress.dart';

class GetBudgetProgress {
  final BudgetRepository repository;

  GetBudgetProgress({required this.repository});

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.

  Future<Either<Failure, BudgetProgress>> call({
    required String budgetId,
    required double spentAmount,
  }) async {
    final result = await repository.getBudgetById(budgetId);

    return result.fold((failure) => Left(failure), (budget) {
      final effectiveBudget =
          budget.amount + (budget.rolloverEnabled ? budget.rolloverAmount : 0);
      final percentage = effectiveBudget > 0
          ? (spentAmount / effectiveBudget) * 100
          : 0.0;
      final periodRange = BudgetPeriodUtils.calculateCurrentPeriod(
        budget.startDate,
        budget.period,
      );

      return Right(
        BudgetProgress(
          budgetId: budgetId,
          budgetAmount: budget.amount,
          effectiveAmount: effectiveBudget,
          spentAmount: spentAmount,
          rolloverAmount: budget.rolloverAmount,
          percentage: percentage,
          isOverBudget: spentAmount > effectiveBudget,
          name: budget.name,
          periodRange: periodRange,
          period: budget.period,
        ),
      );
    });
  }
}
