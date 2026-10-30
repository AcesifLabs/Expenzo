import 'package:equatable/equatable.dart';

import '../../domain/entities/budget_plan_snapshot.dart';
import '../../domain/entities/plan_row.dart';

enum BudgetPlanSaveStatus { idle, saving, saved, failed }

sealed class BudgetPlanState extends Equatable {
  @override
  List<Object?> get props => [];

  const BudgetPlanState();
}

class BudgetPlanLoading extends BudgetPlanState {
  const BudgetPlanLoading();
}

class BudgetPlanLoadFailed extends BudgetPlanState {
  final String message;

  @override
  List<Object?> get props => [message];

  const BudgetPlanLoadFailed(this.message);
}

class BudgetPlanEditing extends BudgetPlanState {
  final BudgetPlanSnapshot stored;
  final double? income;
  final List<PlanRow> rows;
  final BudgetPlanSaveStatus status;

  /// A blank income field keeps the stored income on save, so the plan
  /// is measured against that one too.
  double get base =>
      (income ?? stored.monthlyIncome ?? 0) - stored.recurringTotal;

  @override
  List<Object?> get props => [stored, income, rows, status];

  const BudgetPlanEditing({
    required this.stored,
    required this.income,
    required this.rows,
    this.status = BudgetPlanSaveStatus.idle,
  });

  BudgetPlanEditing copyWith({
    double? income,
    bool clearIncome = false,
    List<PlanRow>? rows,
    BudgetPlanSaveStatus? status,
  }) {
    return BudgetPlanEditing(
      stored: stored,
      income: clearIncome ? null : income ?? this.income,
      rows: rows ?? this.rows,
      status: status ?? this.status,
    );
  }
}
