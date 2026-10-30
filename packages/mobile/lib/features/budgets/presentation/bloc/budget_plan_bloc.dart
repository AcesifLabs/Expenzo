import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import 'package:expense_tracker/core/error/failure_message.dart';

import '../../domain/budget_plan.dart';
import '../../domain/usecases/get_budget_plan.dart';
import '../../domain/usecases/save_budget_plan.dart';
import 'budget_plan_event.dart';
import 'budget_plan_state.dart';

class BudgetPlanBloc extends Bloc<BudgetPlanEvent, BudgetPlanState> {
  final GetBudgetPlan getBudgetPlan;
  final SaveBudgetPlan saveBudgetPlan;

  BudgetPlanBloc({required this.getBudgetPlan, required this.saveBudgetPlan})
    : super(const BudgetPlanLoading()) {
    on<BudgetPlanLoadRequested>(_onLoad, transformer: droppable());
    on<BudgetPlanIncomeChanged>(_onIncome, transformer: sequential());
    on<BudgetPlanRowsChanged>(_onRows, transformer: sequential());
    on<BudgetPlanSaveRequested>(_onSave, transformer: droppable());
  }

  Future<void> _onLoad(
    BudgetPlanLoadRequested event,
    Emitter<BudgetPlanState> emit,
  ) async {
    emit(const BudgetPlanLoading());
    await _load(emit);
  }

  void _onIncome(BudgetPlanIncomeChanged event, Emitter<BudgetPlanState> emit) {
    if (state case final BudgetPlanEditing editing) {
      emit(
        editing.copyWith(
          income: event.income,
          clearIncome: event.income == null,
        ),
      );
    }
  }

  void _onRows(BudgetPlanRowsChanged event, Emitter<BudgetPlanState> emit) {
    if (state case final BudgetPlanEditing editing) {
      emit(editing.copyWith(rows: event.rows));
    }
  }

  /// A failed save may have applied some changes, so it reloads what is
  /// stored after reporting the failure.
  Future<void> _onSave(
    BudgetPlanSaveRequested event,
    Emitter<BudgetPlanState> emit,
  ) async {
    final editing = state;
    if (editing is! BudgetPlanEditing ||
        editing.status == BudgetPlanSaveStatus.saving ||
        editing.status == BudgetPlanSaveStatus.saved) {
      return;
    }
    emit(editing.copyWith(status: BudgetPlanSaveStatus.saving));
    final result = await saveBudgetPlan(
      SaveBudgetPlanParams(
        changes: event.changes,
        monthlyIncome: editing.income,
      ),
    );

    if (result.isRight()) {
      emit(editing.copyWith(status: BudgetPlanSaveStatus.saved));

      return;
    }
    emit(editing.copyWith(status: BudgetPlanSaveStatus.failed));
    await _load(emit);
  }

  Future<void> _load(Emitter<BudgetPlanState> emit) async {
    final result = await getBudgetPlan();

    emit(
      result.fold(
        (failure) => BudgetPlanLoadFailed(failureText(failure)),
        (stored) => BudgetPlanEditing(
          stored: stored,
          income: stored.monthlyIncome,
          rows: [for (final budget in stored.budgets) planRowFor(budget)],
        ),
      ),
    );
  }
}
