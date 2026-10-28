import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';

class BudgetProgress {
  final String budgetId;
  final double budgetAmount;
  final double effectiveAmount;
  final double spentAmount;
  final double rolloverAmount;
  final double percentage;
  final bool isOverBudget;
  final String name;
  final DateTimeRange periodRange;
  final BudgetPeriod period;

  final String? groupId;

  const BudgetProgress({
    required this.budgetId,
    required this.budgetAmount,
    required this.effectiveAmount,
    required this.spentAmount,
    required this.rolloverAmount,
    required this.percentage,
    required this.isOverBudget,
    required this.name,
    required this.periodRange,
    required this.period,
    this.groupId,
  });
}
