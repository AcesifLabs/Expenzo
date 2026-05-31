import 'package:equatable/equatable.dart';
import '../../../budgets/domain/entities/budget.dart';

abstract class BudgetEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const BudgetEvent();
}

class LoadBudgets extends BudgetEvent {}

class CreateBudgetEvent extends BudgetEvent {
  final Budget budget;

  @override
  List<Object?> get props => [budget];

  const CreateBudgetEvent(this.budget);
}

class UpdateBudgetEvent extends BudgetEvent {
  final Budget budget;

  @override
  List<Object?> get props => [budget];

  const UpdateBudgetEvent(this.budget);
}

class DeleteBudgetEvent extends BudgetEvent {
  final String id;

  @override
  List<Object?> get props => [id];

  const DeleteBudgetEvent(this.id);
}

class LoadBudgetTransactions extends BudgetEvent {
  final String budgetId;

  @override
  List<Object?> get props => [budgetId];

  const LoadBudgetTransactions(this.budgetId);
}

class LoadBudgetTransactions extends BudgetEvent {
  final String budgetId;

  const LoadBudgetTransactions(this.budgetId);

  @override
  List<Object?> get props => [budgetId];
}
