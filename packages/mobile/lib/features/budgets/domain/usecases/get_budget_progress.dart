import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/utils/budget_period_utils.dart';
import '../repositories/budget_repository.dart';

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
          categoryId: budget.categoryId,
          periodRange: periodRange,
          period: budget.period,
        ),
      );
    });
  }
}

class BudgetProgress {
  final String budgetId;
  final double budgetAmount;
  final double effectiveAmount;
  final double spentAmount;
  final double rolloverAmount;
  final double percentage;
  final bool isOverBudget;
  final String? categoryId;
  final DateTimeRange periodRange;
  final BudgetPeriod period;

  const BudgetProgress({
    required this.budgetId,
    required this.budgetAmount,
    required this.effectiveAmount,
    required this.spentAmount,
    required this.rolloverAmount,
    required this.percentage,
    required this.isOverBudget,
    this.categoryId,
    required this.periodRange,
    required this.period,
  });
}
