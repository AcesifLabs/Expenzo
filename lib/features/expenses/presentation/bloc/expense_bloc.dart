import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/update_expense.dart';
import 'expense_event.dart';
import 'expense_state.dart';

const _pageSize = 50;

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpenses getExpenses;
  final AddExpense addExpense;
  final UpdateExpense updateExpense;
  final DeleteExpense deleteExpense;

  ExpenseBloc({
    required this.getExpenses,
    required this.addExpense,
    required this.updateExpense,
    required this.deleteExpense,
  }) : super(const ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<LoadMoreExpenses>(_onLoadMoreExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
    on<RefreshExpenses>(_onRefreshExpenses);
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());
    final result = await getExpenses(const GetExpensesParams(limit: _pageSize));
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expenses) => emit(
        ExpenseLoaded(
          expenses: expenses,
          total: expenses.length,
          hasMore: expenses.length >= _pageSize,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreExpenses(
    LoadMoreExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ExpenseLoaded || currentState.hasMore == false) {
      return; // Nothing more to load
    }

    // Emit loading state with current expenses
    emit(
      ExpenseLoadingMore(
        currentExpenses: currentState.expenses,
        total: currentState.total,
      ),
    );

    final result = await getExpenses(
      GetExpensesParams(limit: _pageSize, offset: currentState.expenses.length),
    );

    result.fold((failure) => emit(ExpenseError(failure.message)), (
      newExpenses,
    ) {
      final allExpenses = [...currentState.expenses, ...newExpenses];
      emit(
        ExpenseLoaded(
          expenses: allExpenses,
          total: allExpenses.length,
          hasMore: newExpenses.length >= _pageSize,
        ),
      );
    });
  }

  Future<void> _onAddExpense(
    AddExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final result = await addExpense(event.expense);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (_) => add(const LoadExpenses()), // Reload from beginning
    );
  }

  Future<void> _onUpdateExpense(
    UpdateExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final result = await updateExpense(event.expense);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (_) => add(const LoadExpenses()), // Reload from beginning
    );
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final result = await deleteExpense(event.id);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (_) => add(const LoadExpenses()), // Reload from beginning
    );
  }

  Future<void> _onRefreshExpenses(
    RefreshExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    add(const LoadExpenses());
  }
}
