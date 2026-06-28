import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/utils/budget_period_utils.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';
import 'get_budget_progress.dart';

class GetBudgetsWithProgress {
  final BudgetRepository budgetRepository;
  final RecordRepository recordRepository;
  final CategoryRepository categoryRepository;

  GetBudgetsWithProgress({
    required this.budgetRepository,
    required this.recordRepository,
    required this.categoryRepository,
  });

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

      final catId = budget.categoryId;
      double spentAmount = 0;

      if (catId != null) {
        final spendingResult = await recordRepository.getCategorySpending(
          catId,
          periodRange.start,
          periodRange.end,
        );
        spentAmount = spendingResult.fold((_) => 0.0, (spent) => spent);
      } else {
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

    results.sort((a, b) => b.percentage.compareTo(a.percentage));

    if (limit != null && limit > 0 && limit < results.length) {
      return Right(results.sublist(0, limit));
    }

    return Right(results);
  }
}
