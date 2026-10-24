import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/utils/budget_period_utils.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';
import 'get_budget_progress.dart';

/// The server's spent for a Shared Budget in the period starting at
/// [periodStart], or null when it has none for that period.
typedef SharedSpentLookup =
    double? Function(String budgetId, DateTime periodStart);

class GetBudgetsWithProgress {
  final BudgetRepository budgetRepository;
  final RecordRepository recordRepository;

  /// Shared Budget progress comes from the server (CONTEXT.md Shared
  /// Budget): local Records are only this member's share of it.
  final SharedSpentLookup? sharedSpent;

  GetBudgetsWithProgress({
    required this.budgetRepository,
    required this.recordRepository,
    this.sharedSpent,
  });

  Future<Either<Failure, List<BudgetProgress>>> call({int? limit}) async {
    final budgetsResult = await budgetRepository.getBudgets();
    final budgets = budgetsResult
        .getOrElse(() => <Budget>[])
        .where((budget) => budget.isEnabled)
        .toList();
    if (budgets.isEmpty) return const Right([]);

    final periods = {
      for (final budget in budgets)
        budget.id ?? '': BudgetPeriodUtils.calculateCurrentPeriod(
          budget.startDate,
          budget.period,
        ),
    };
    // One query for every budget's spend, not one per budget: this runs
    // after every save (budget alerts) and on every budget screen load.
    final spendingResult = await recordRepository.getSpendingForBudgets({
      for (final entry in periods.entries)
        entry.key: (start: entry.value.start, end: entry.value.end),
    });
    final spentById = spendingResult.fold(
      (_) => const <String, double>{},
      (spent) => spent,
    );

    final results = <BudgetProgress>[];
    for (final budget in budgets) {
      final id = budget.id ?? '';
      final localSpent = spentById[id] ?? 0.0;
      final spentAmount = budget.groupId == null
          ? localSpent
          : sharedSpent?.call(id, periods[id]!.start) ?? localSpent;
      final effectiveBudget =
          budget.amount + (budget.rolloverEnabled ? budget.rolloverAmount : 0);
      final percentage = effectiveBudget > 0
          ? (spentAmount / effectiveBudget) * 100
          : 0.0;

      results.add(
        BudgetProgress(
          budgetId: id,
          budgetAmount: budget.amount,
          effectiveAmount: effectiveBudget,
          spentAmount: spentAmount,
          rolloverAmount: budget.rolloverAmount,
          percentage: percentage,
          isOverBudget: spentAmount > effectiveBudget,
          name: budget.name,
          periodRange: periods[id]!,
          period: budget.period,
          groupId: budget.groupId,
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
