import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import '../../domain/usecases/get_budgets.dart';
import '../../domain/usecases/create_budget.dart';
import '../../domain/usecases/update_budget.dart';
import '../../domain/usecases/delete_budget.dart';
import '../../domain/usecases/get_budgets_with_progress.dart';
import '../../domain/usecases/get_budget_transactions.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final GetBudgets getBudgets;
  final CreateBudget createBudget;
  final UpdateBudget updateBudget;
  final DeleteBudget deleteBudget;
  final GetBudgetsWithProgress getBudgetsWithProgress;
  final GetBudgetTransactions getBudgetTransactions;

  BudgetBloc({
    required this.getBudgets,
    required this.createBudget,
    required this.updateBudget,
    required this.deleteBudget,
    required this.getBudgetsWithProgress,
    required this.getBudgetTransactions,
  }) : super(BudgetInitial()) {
    on<LoadBudgets>(_onLoadBudgets, transformer: concurrent());
    on<CreateBudgetEvent>(_onCreateBudget, transformer: sequential());
    on<UpdateBudgetEvent>(_onUpdateBudget, transformer: sequential());
    on<DeleteBudgetEvent>(_onDeleteBudget, transformer: sequential());
    on<LoadBudgetTransactions>(
      _onLoadBudgetTransactions,
      transformer: concurrent(),
    );
  }

  Future<void> _onLoadBudgets(
    LoadBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());

    final result = await getBudgets();

    await result.fold((failure) async => emit(BudgetError(failure.message)), (
      budgets,
    ) async {
      final progressResult = await getBudgetsWithProgress(
        limit: budgets.length,
      );
      final progressList = progressResult.getOrElse(() => []);
      emit(
        BudgetLoaded(
          budgets,
          progressByBudgetId: {
            for (final progress in progressList) progress.budgetId: progress,
          },
        ),
      );
    });
  }

  Future<void> _onCreateBudget(
    CreateBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());

    final result = await createBudget(event.budget);

    result.fold((failure) => emit(BudgetError(failure.message)), (budget) {
      emit(const BudgetOperationSuccess());
      add(LoadBudgets());
    });
  }

  Future<void> _onUpdateBudget(
    UpdateBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());

    final result = await updateBudget(event.budget);

    result.fold((failure) => emit(BudgetError(failure.message)), (budget) {
      emit(const BudgetOperationSuccess());
      add(LoadBudgets());
    });
  }

  Future<void> _onDeleteBudget(
    DeleteBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());

    final result = await deleteBudget(event.id);

    result.fold((failure) => emit(BudgetError(failure.message)), (_) {
      emit(const BudgetOperationSuccess());
      add(LoadBudgets());
    });
  }

  Future<void> _onLoadBudgetTransactions(
    LoadBudgetTransactions event,
    Emitter<BudgetState> emit,
  ) async {
    final current = state;
    if (current is! BudgetLoaded) return;

    emit(
      current.copyWith(
        selectedBudgetId: event.budgetId,
        isLoadingTransactions: true,
        selectedBudgetTransactions: const [],
      ),
    );

    final result = await getBudgetTransactions(event.budgetId);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (records) => emit(
        current.copyWith(
          selectedBudgetId: event.budgetId,
          selectedBudgetTransactions: records,
          isLoadingTransactions: false,
        ),
      ),
    );
  }
}
