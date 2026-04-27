import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
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
  final ExpenseRepository expenseRepository;

  StreamSubscription<List<Expense>>? _expensesSubscription;

  ExpenseBloc({
    required this.getExpenses,
    required this.addExpense,
    required this.updateExpense,
    required this.deleteExpense,
    required this.expenseRepository,
  }) : super(const ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<LoadMoreExpenses>(_onLoadMoreExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
    on<RefreshExpenses>(_onRefreshExpenses);
    on<_ExpensesUpdated>(_onExpensesUpdated);
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());

    // Start listening to the reactive stream — DB changes auto-propagate
    await _expensesSubscription?.cancel();
    _expensesSubscription = expenseRepository
        .watchExpenses(limit: _pageSize)
        .listen((expenses) {
          if (!isClosed) {
            add(_ExpensesUpdated(expenses));
          }
        });

    // Also do a manual fetch for the initial page load
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

  /// Handles reactive stream updates — when DB changes (add/update/delete),
  /// this fires automatically without needing explicit reloads.
  Future<void> _onExpensesUpdated(
    _ExpensesUpdated event,
    Emitter<ExpenseState> emit,
  ) async {
    final expenses = event.expenses;

    emit(
      ExpenseLoaded(
        expenses: expenses,
        total: expenses.length,
        hasMore: expenses.length >= _pageSize,
      ),
    );
  }

  Future<void> _onLoadMoreExpenses(
    LoadMoreExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ExpenseLoaded || currentState.hasMore == false) {
      return;
    }

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
      // No manual reload needed — stream will auto-trigger _ExpensesUpdated
      (_) {},
    );
  }

  Future<void> _onUpdateExpense(
    UpdateExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final result = await updateExpense(event.expense);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      // No manual reload needed — stream will auto-trigger _ExpensesUpdated
      (_) {},
    );
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final result = await deleteExpense(event.id);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      // No manual reload needed — stream will auto-trigger _ExpensesUpdated
      (_) {},
    );
  }

  Future<void> _onRefreshExpenses(
    RefreshExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    // Re-trigger initial load (which also re-subscribes to the stream)
    add(const LoadExpenses());
  }

  @override
  Future<void> close() {
    _expensesSubscription?.cancel();
    return super.close();
  }
}

/// Internal event fired by the reactive stream subscription.
class _ExpensesUpdated extends ExpenseEvent {
  final List<Expense> expenses;
  const _ExpensesUpdated(this.expenses);

  @override
  List<Object?> get props => [expenses];
}
