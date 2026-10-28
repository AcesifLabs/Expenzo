import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/utils/budget_period_utils.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart'
    hide DateTimeRange;
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';
import 'get_budget_progress.dart';

typedef SharedSpentLookup =
    double? Function(String budgetId, DateTime periodStart);

class GetBudgetsWithProgress {
  final BudgetRepository budgetRepository;
  final RecordRepository recordRepository;

  final SharedSpentLookup sharedSpent;

  GetBudgetsWithProgress({
    required this.budgetRepository,
    required this.recordRepository,
    required this.sharedSpent,
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

    final spentById = await _spending({
      for (final entry in periods.entries)
        entry.key: (start: entry.value.start, end: entry.value.end),
    });

    final previous = _previousPeriods(budgets, periods);
    final previousSpentById = previous.isEmpty
        ? const <String, double>{}
        : await _spending(previous);

    final results = [
      for (final budget in budgets)
        _progress(
          budget,
          periods[budget.id ?? '']!,
          spent: spentById,
          previousSpent: previousSpentById,
        ),
    ]..sort((a, b) => b.percentage.compareTo(a.percentage));

    if (limit != null && limit > 0 && limit < results.length) {
      return Right(results.sublist(0, limit));
    }

    return Right(results);
  }

  Map<String, ({DateTime start, DateTime end})> _previousPeriods(
    List<Budget> budgets,
    Map<String, DateTimeRange> periods,
  ) {
    final result = <String, ({DateTime start, DateTime end})>{};
    for (final budget in budgets) {
      final id = budget.id ?? '';
      if (!budget.rolloverEnabled || budget.groupId != null) continue;
      final previous = BudgetPeriodUtils.previousPeriod(
        budget.startDate,
        budget.period,
        periods[id]!,
      );
      final started = budget.startDate;
      final firstDay = DateTime(started.year, started.month, started.day);
      if (previous.start.isBefore(firstDay)) continue;
      result[id] = (start: previous.start, end: previous.end);
    }

    return result;
  }

  Future<Map<String, double>> _spending(
    Map<String, ({DateTime start, DateTime end})> periods,
  ) async => (await recordRepository.getSpendingForBudgets(
    periods,
  )).fold((_) => const <String, double>{}, (spent) => spent);

  BudgetProgress _progress(
    Budget budget,
    DateTimeRange period, {
    required Map<String, double> spent,
    required Map<String, double> previousSpent,
  }) {
    final id = budget.id ?? '';
    final localSpent = spent[id] ?? 0.0;
    final spentAmount = budget.groupId == null
        ? localSpent
        : sharedSpent(id, period.start) ?? localSpent;
    final spentBefore = previousSpent[id];

    final rollover = spentBefore == null
        ? 0.0
        : max(0.0, budget.amount - spentBefore);
    final effectiveBudget = budget.amount + rollover;

    return BudgetProgress(
      budgetId: id,
      budgetAmount: budget.amount,
      effectiveAmount: effectiveBudget,
      spentAmount: spentAmount,
      rolloverAmount: rollover,
      percentage: effectiveBudget > 0
          ? (spentAmount / effectiveBudget) * 100
          : 0.0,
      isOverBudget: spentAmount > effectiveBudget,
      name: budget.name,
      periodRange: period,
      period: budget.period,
      groupId: budget.groupId,
    );
  }
}
