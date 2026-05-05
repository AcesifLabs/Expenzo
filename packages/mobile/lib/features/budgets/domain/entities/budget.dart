import 'package:equatable/equatable.dart';

enum BudgetPeriod { weekly, monthly, yearly }

class Budget extends Equatable {
  final String? id;
  final String? categoryId; // null = overall budget
  final double amount;
  final BudgetPeriod period;
  final DateTime startDate;
  final bool rolloverEnabled;
  final double rolloverAmount; // unspent carry-forward amount
  final bool isEnabled;

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
}
