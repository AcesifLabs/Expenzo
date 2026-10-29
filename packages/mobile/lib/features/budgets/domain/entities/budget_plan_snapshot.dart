import 'package:equatable/equatable.dart';

import 'budget.dart';

class BudgetPlanSnapshot extends Equatable {
  final double? monthlyIncome;
  final double recurringTotal;
  final List<Budget> budgets;

  double get base => (monthlyIncome ?? 0) - recurringTotal;

  @override
  List<Object?> get props => [monthlyIncome, recurringTotal, budgets];

  const BudgetPlanSnapshot({
    required this.monthlyIncome,
    required this.recurringTotal,
    required this.budgets,
  });
}
