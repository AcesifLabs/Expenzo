import 'package:equatable/equatable.dart';
import '../../../budgets/domain/entities/budget.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

class LoadBudgets extends BudgetEvent {}

class CreateBudgetEvent extends BudgetEvent {
  final Budget budget;

  const CreateBudgetEvent(this.budget);

  @override
  List<Object?> get props => [budget];
}

class UpdateBudgetEvent extends BudgetEvent {
  final Budget budget;

  const UpdateBudgetEvent(this.budget);

  @override
  List<Object?> get props => [budget];
}

class DeleteBudgetEvent extends BudgetEvent {
  final String id;

  const DeleteBudgetEvent(this.id);

  @override
  List<Object?> get props => [id];
}
