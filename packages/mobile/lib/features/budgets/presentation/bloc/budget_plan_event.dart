import 'package:equatable/equatable.dart';

import '../../domain/entities/plan_changes.dart';
import '../../domain/entities/plan_row.dart';

sealed class BudgetPlanEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const BudgetPlanEvent();
}

class BudgetPlanLoadRequested extends BudgetPlanEvent {
  const BudgetPlanLoadRequested();
}

class BudgetPlanIncomeChanged extends BudgetPlanEvent {
  final double? income;

  @override
  List<Object?> get props => [income];

  const BudgetPlanIncomeChanged(this.income);
}

class BudgetPlanRowsChanged extends BudgetPlanEvent {
  final List<PlanRow> rows;

  @override
  List<Object?> get props => [rows];

  const BudgetPlanRowsChanged(this.rows);
}

/// Carries the changes the page showed the user, so the deletions they
/// confirmed are exactly the ones written.
class BudgetPlanSaveRequested extends BudgetPlanEvent {
  final PlanChanges changes;

  @override
  List<Object?> get props => [changes];

  const BudgetPlanSaveRequested(this.changes);
}
