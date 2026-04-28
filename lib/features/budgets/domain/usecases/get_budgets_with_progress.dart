import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/utils/budget_period_utils.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';
import 'get_budget_progress.dart';

/// Fetches all budgets with calculated spending progress for the current period.
class GetBudgetsWithProgress {
  final BudgetRepository budgetRepository;
  final RecordRepository recordRepository;
  final CategoryRepository categoryRepository;

  GetBudgetsWithProgress({
    required this.budgetRepository,
    required this.recordRepository,
    required this.categoryRepository,
  });

  /// Returns budgets sorted by utilization (highest first).
  /// [limit] optional — set to 5 for the dashboard preview.
  Future<Either<Failure, List<BudgetProgress>>> call({int? limit}) async {
    final budgetsResult = await budgetRepository.getBudgets();
    final budgets = budgetsResult.getOrElse(() => <Budget>[]);

    final results = <BudgetProgress>[];

    for (final budget in budgets) {
      if (!budget.isEnabled) continue;

      final periodRange = BudgetPeriodUtils.calculateCurrentPeriod(
        budget.startDate,
        budget.period,
      );

      // Convert budget's string categoryId to int for record lookup
      final intCategoryId = int.tryParse(budget.categoryId ?? '');
      double spentAmount = 0;

      if (intCategoryId != null) {
        final spendingResult = await recordRepository.getCategorySpending(
          intCategoryId,
          periodRange.start,
          periodRange.end,
        );
        spentAmount = spendingResult.fold((_) => 0.0, (spent) => spent);
      } else {
        // Overall budget: sum all expenses in the period
        final spendingResult = await recordRepository.getTotalSpending(
          periodRange.start,
          periodRange.end,
        );
        spentAmount = spendingResult.fold((_) => 0.0, (spent) => spent);
      }

      final effectiveBudget =
          budget.amount + (budget.rolloverEnabled ? budget.rolloverAmount : 0);
      final percentage = effectiveBudget > 0
          ? (spentAmount / effectiveBudget) * 100
          : 0.0;

      results.add(
        BudgetProgress(
          budgetId: budget.id ?? '',
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
    }

    // Sort by percentage descending (highest utilization first)
    results.sort((a, b) => b.percentage.compareTo(a.percentage));

    if (limit != null && limit > 0 && limit < results.length) {
      return Right(results.sublist(0, limit));
    }

    return Right(results);
  }
}
