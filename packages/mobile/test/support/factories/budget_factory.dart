import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget.dart';

/// Creates a [Budget] for tests. All params optional with deterministic defaults.
Budget makeBudget({
  String? id,
  String? categoryId,
  double? amount,
  BudgetPeriod? period,
  DateTime? startDate,
  bool? rolloverEnabled,
  double? rolloverAmount,
  bool? isEnabled,
}) {
  return Budget(
    id: id ?? 'budget-0001',
    categoryId: categoryId,
    amount: amount ?? 500.00,
    period: period ?? BudgetPeriod.monthly,
    startDate: startDate ?? DateTime(2024, 1, 1),
    rolloverEnabled: rolloverEnabled ?? false,
    rolloverAmount: rolloverAmount ?? 0,
    isEnabled: isEnabled ?? true,
  );
}
