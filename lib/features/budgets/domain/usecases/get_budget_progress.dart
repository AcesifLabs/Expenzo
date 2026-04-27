import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../repositories/budget_repository.dart';

class BudgetProgress {
  final String budgetId;
  final double budgetAmount;
  final double spentAmount;
  final double rolloverAmount;
  final double percentage;
  final bool isOverBudget;

  const BudgetProgress({
    required this.budgetId,
    required this.budgetAmount,
    required this.spentAmount,
    required this.rolloverAmount,
    required this.percentage,
    required this.isOverBudget,
  });
}

class GetBudgetProgress {
  final BudgetRepository repository;

  GetBudgetProgress({required this.repository});

  Future<Either<Failure, BudgetProgress>> call({
    required String budgetId,
    required double spentAmount,
  }) async {
    final result = await repository.getBudgetById(budgetId);

    return result.fold((failure) => Left(failure), (budget) {
      // Calculate effective budget with rollover
      final effectiveBudget =
          budget.amount + (budget.rolloverEnabled ? budget.rolloverAmount : 0);

      // Calculate percentage
      final percentage = effectiveBudget > 0
          ? (spentAmount / effectiveBudget) * 100
          : 0.0;

      return Right(
        BudgetProgress(
          budgetId: budgetId,
          budgetAmount: budget.amount,
          spentAmount: spentAmount,
          rolloverAmount: budget.rolloverAmount,
          percentage: percentage,
          isOverBudget: spentAmount > effectiveBudget,
        ),
      );
    });
  }
}
