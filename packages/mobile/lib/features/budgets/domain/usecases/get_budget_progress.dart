import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

/// Enhanced progress info for a single budget, including category display data.
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

/// Deprecated — use [GetBudgetsWithProgress] for automatic calculation.
/// Kept for backward compatibility.
class GetBudgetProgress {
  final BudgetRepository repository;

  GetBudgetProgress({required this.repository});

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
      final now = DateTime.now();
      final periodRange = DateTimeRange(
        start: now, // approximate; caller should use GetBudgetsWithProgress
        end: now.add(const Duration(days: 30)),
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
