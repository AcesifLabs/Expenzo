import 'package:equatable/equatable.dart';
import '../../domain/entities/budget.dart';
import '../../domain/usecases/get_budget_progress.dart';
import '../../../records/domain/entities/record.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final List<Budget> budgets;
  final Map<String, BudgetProgress> progressByBudgetId;
  final String? selectedBudgetId;
  final List<Record> selectedBudgetTransactions;
  final bool isLoadingTransactions;

  const BudgetLoaded(
    this.budgets, {
    this.progressByBudgetId = const {},
    this.selectedBudgetId,
    this.selectedBudgetTransactions = const [],
    this.isLoadingTransactions = false,
  });

  BudgetLoaded copyWith({
    List<Budget>? budgets,
    Map<String, BudgetProgress>? progressByBudgetId,
    String? selectedBudgetId,
    List<Record>? selectedBudgetTransactions,
    bool? isLoadingTransactions,
  }) {
    return BudgetLoaded(
      budgets ?? this.budgets,
      progressByBudgetId: progressByBudgetId ?? this.progressByBudgetId,
      selectedBudgetId: selectedBudgetId ?? this.selectedBudgetId,
      selectedBudgetTransactions:
          selectedBudgetTransactions ?? this.selectedBudgetTransactions,
      isLoadingTransactions:
          isLoadingTransactions ?? this.isLoadingTransactions,
    );
  }

  @override
  List<Object?> get props => [
    budgets,
    progressByBudgetId,
    selectedBudgetId,
    selectedBudgetTransactions,
    isLoadingTransactions,
  ];
}

class BudgetError extends BudgetState {
  final String message;

  const BudgetError(this.message);

  @override
  List<Object?> get props => [message];
}

class BudgetOperationSuccess extends BudgetState {
  final String message;

  const BudgetOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
