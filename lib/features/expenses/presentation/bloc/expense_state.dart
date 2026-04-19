import 'package:equatable/equatable.dart';
import '../../domain/entities/expense.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

class ExpenseLoadingMore extends ExpenseState {
  final List<Expense> currentExpenses;
  final int total;

  const ExpenseLoadingMore({
    required this.currentExpenses,
    required this.total,
  });

  @override
  List<Object?> get props => [currentExpenses, total];
}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;
  final int total;
  final bool hasMore;

  const ExpenseLoaded({
    required this.expenses,
    this.total = 0,
    this.hasMore = false,
  });

  ExpenseLoaded copyWith({List<Expense>? expenses, int? total, bool? hasMore}) {
    return ExpenseLoaded(
      expenses: expenses ?? this.expenses,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [expenses, total, hasMore];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object?> get props => [message];
}
