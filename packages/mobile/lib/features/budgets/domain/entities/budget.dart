import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';

/// Distinguishes "not passed" from "set to null" for [Budget.groupId] in
/// [Budget.copyWith], the same way [Record.copyWith] does.
class _BudgetSentinel {
  const _BudgetSentinel();
}

const _sentinel = _BudgetSentinel();

class Budget extends Equatable {
  final String? id;
  final String name;
  final double amount;
  final BudgetPeriod period;
  final DateTime startDate;
  final bool rolloverEnabled;
  final double rolloverAmount;
  final bool isEnabled;

  /// The Family Group this budget is shared into (a Shared Budget), or null.
  final String? groupId;

  bool get isShared => groupId != null;

  @override
  List<Object?> get props => [
    id,
    name,
    amount,
    period,
    startDate,
    rolloverEnabled,
    rolloverAmount,
    isEnabled,
    groupId,
  ];

  const Budget({
    this.id,
    required this.name,
    required this.amount,
    required this.period,
    required this.startDate,
    this.rolloverEnabled = false,
    this.rolloverAmount = 0,
    this.isEnabled = true,
    this.groupId,
  });

  Budget copyWith({
    String? id,
    String? name,
    double? amount,
    BudgetPeriod? period,
    DateTime? startDate,
    bool? rolloverEnabled,
    double? rolloverAmount,
    bool? isEnabled,
    Object? groupId = _sentinel,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      rolloverEnabled: rolloverEnabled ?? this.rolloverEnabled,
      rolloverAmount: rolloverAmount ?? this.rolloverAmount,
      isEnabled: isEnabled ?? this.isEnabled,
      groupId: groupId == _sentinel ? this.groupId : groupId as String?,
    );
  }
}
