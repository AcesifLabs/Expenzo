import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';

/// `GET /groups/:id/summary` (ADR 0008). Only Records linked to Shared
/// Budgets count; there is no family income figure.
class GroupSummary extends Equatable {
  final String groupId;
  final String currencyCode;
  final double? monthlyBudget;
  final double spent;
  final double planned;
  final double monthSpent;

  /// Highest spender first.
  final List<MemberSpending> members;
  final List<SharedBudgetProgress> sharedBudgets;
  final DateTime generatedAt;

  @override
  List<Object?> get props => [
    groupId,
    currencyCode,
    monthlyBudget,
    spent,
    planned,
    monthSpent,
    members,
    sharedBudgets,
    generatedAt,
  ];

  const GroupSummary({
    required this.groupId,
    required this.currencyCode,
    this.monthlyBudget,
    required this.spent,
    required this.planned,
    required this.monthSpent,
    required this.members,
    required this.sharedBudgets,
    required this.generatedAt,
  });

  SharedBudgetProgress? budget(String id) {
    for (final budget in sharedBudgets) {
      if (budget.id == id) return budget;
    }

    return null;
  }
}

class MemberSpending extends Equatable {
  final String userId;
  final String? displayName;
  final double spent;

  @override
  List<Object?> get props => [userId, displayName, spent];

  const MemberSpending({
    required this.userId,
    this.displayName,
    required this.spent,
  });
}

class SharedBudgetProgress extends Equatable {
  final String id;
  final String name;
  final BudgetPeriod period;
  final double amount;
  final double effectiveAmount;
  final double spent;

  /// The period the server counted; a summary from an earlier period must
  /// not be shown for the current one.
  final DateTime periodStart;
  final DateTime periodEnd;

  /// Spent as a share of [effectiveAmount]; 0 when nothing is planned.
  double get ratio => effectiveAmount > 0 ? spent / effectiveAmount : 0;

  @override
  List<Object?> get props => [
    id,
    name,
    period,
    amount,
    effectiveAmount,
    spent,
    periodStart,
    periodEnd,
  ];

  const SharedBudgetProgress({
    required this.id,
    required this.name,
    required this.period,
    required this.amount,
    required this.effectiveAmount,
    required this.spent,
    required this.periodStart,
    required this.periodEnd,
  });
}
