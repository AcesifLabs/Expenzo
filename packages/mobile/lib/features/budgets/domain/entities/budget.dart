import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';

class Budget extends Equatable {
  final String? id;
  final String? categoryId;
  final double amount;
  final BudgetPeriod period;
  final DateTime startDate;
  final bool rolloverEnabled;
  final double rolloverAmount;
  final bool isEnabled;

  @override
  List<Object?> get props => [
    id,
    categoryId,
    amount,
    period,
    startDate,
    rolloverEnabled,
    rolloverAmount,
    isEnabled,
  ];

  const Budget({
    this.id,
    this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
    this.rolloverEnabled = false,
    this.rolloverAmount = 0,
    this.isEnabled = true,
  });

  Budget copyWith({
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
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      rolloverEnabled: rolloverEnabled ?? this.rolloverEnabled,
      rolloverAmount: rolloverAmount ?? this.rolloverAmount,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
