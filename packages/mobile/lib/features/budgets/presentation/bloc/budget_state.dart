import 'package:equatable/equatable.dart';
import '../../domain/entities/budget.dart';
import '../../domain/usecases/get_budget_progress.dart';
import '../../../records/domain/entities/record.dart';

sealed class BudgetState extends Equatable {
  @override
  List<Object?> get props => [];

  const BudgetState();
}

class BudgetInitial extends BudgetState {
  const BudgetInitial();
}

class BudgetLoading extends BudgetState {
  const BudgetLoading();
}

class BudgetLoaded extends BudgetState {
  final List<Budget> budgets;
  final Map<String, BudgetProgress> progressByBudgetId;
  final String? selectedBudgetId;
  final List<Record> selectedBudgetTransactions;
  final bool isLoadingTransactions;

  @override
  List<Object?> get props => [
    budgets,
    progressByBudgetId,
    selectedBudgetId,
    selectedBudgetTransactions,
    isLoadingTransactions,
  ];

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
}

class BudgetError extends BudgetState {
  final String message;

  @override
  List<Object?> get props => [message];

  const BudgetError(this.message);
}

class BudgetOperationSuccess extends BudgetState {
  @override
  List<Object?> get props => [];

  const BudgetOperationSuccess();
}
