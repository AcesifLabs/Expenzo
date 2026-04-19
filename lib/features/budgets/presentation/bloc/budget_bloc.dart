import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_budgets.dart';
import '../../domain/usecases/create_budget.dart';
import '../../domain/usecases/update_budget.dart';
import '../../domain/usecases/delete_budget.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final GetBudgets getBudgets;
  final CreateBudget createBudget;
  final UpdateBudget updateBudget;
  final DeleteBudget deleteBudget;

  BudgetBloc({
    required this.getBudgets,
    required this.createBudget,
    required this.updateBudget,
    required this.deleteBudget,
  }) : super(BudgetInitial()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<CreateBudgetEvent>(_onCreateBudget);
    on<UpdateBudgetEvent>(_onUpdateBudget);
    on<DeleteBudgetEvent>(_onDeleteBudget);
  }

  Future<void> _onLoadBudgets(
    LoadBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());

    final result = await getBudgets();

    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (budgets) => emit(BudgetLoaded(budgets)),
    );
  }

  Future<void> _onCreateBudget(
    CreateBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());

    final result = await createBudget(event.budget);

    result.fold((failure) => emit(BudgetError(failure.message)), (budget) {
      emit(const BudgetOperationSuccess('Budget created successfully'));
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
      emit(const BudgetOperationSuccess('Budget updated successfully'));
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
      emit(const BudgetOperationSuccess('Budget deleted successfully'));
      add(LoadBudgets());
    });
  }
}
