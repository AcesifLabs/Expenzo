import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/error/failures.dart';

import '../../domain/repositories/goal_repository.dart';
import '../../domain/usecases/create_goal.dart';
import '../../domain/usecases/delete_goal.dart';
import '../../domain/usecases/update_goal.dart';
import 'goal_form_event.dart';
import 'goal_form_state.dart';

/// The goal form: edit an existing goal, or create one (Task 22b).
class GoalFormBloc extends Bloc<GoalFormEvent, GoalFormState> {
  final GoalRepository repository;
  final CreateGoal createGoal;
  final UpdateGoal updateGoal;
  final DeleteGoal deleteGoal;

  GoalFormBloc({
    required this.repository,
    required this.createGoal,
    required this.updateGoal,
    required this.deleteGoal,
  }) : super(const GoalFormState()) {
    on<GoalFormLoaded>(_onLoaded, transformer: restartable());
    on<GoalFormStartedNew>(_onStartedNew, transformer: restartable());
    on<GoalFormSaved>(_onSaved, transformer: droppable());
    on<GoalFormCreated>(_onCreated, transformer: droppable());
    on<GoalFormDeleted>(_onDeleted, transformer: droppable());
  }

  Future<void> _onLoaded(
    GoalFormLoaded event,
    Emitter<GoalFormState> emit,
  ) async {
    emit(const GoalFormState());
    final result = await repository.getGoalById(event.id);
    emit(
      result.fold(
        (failure) => GoalFormState(
          status: failure.errorCode == FailureCodes.notFound
              ? GoalFormStatus.notFound
              : GoalFormStatus.failure,
        ),
        (goal) => GoalFormState(goal: goal, status: GoalFormStatus.ready),
      ),
    );
  }

  void _onStartedNew(GoalFormStartedNew event, Emitter<GoalFormState> emit) {
    emit(const GoalFormState(status: GoalFormStatus.ready));
  }

  Future<void> _onSaved(GoalFormSaved event, Emitter<GoalFormState> emit) =>
      _write(emit, () => updateGoal(event.goal), GoalFormStatus.saved);

  Future<void> _onCreated(GoalFormCreated event, Emitter<GoalFormState> emit) =>
      _write(emit, () => createGoal(event.goal), GoalFormStatus.created);

  Future<void> _onDeleted(
    GoalFormDeleted event,
    Emitter<GoalFormState> emit,
  ) async {
    final id = state.goal?.id;
    if (id == null || state.isBusy) return;
    emit(state.copyWith(status: GoalFormStatus.deleting));
    final result = await deleteGoal(id);
    emit(
      result.fold(
        (f) => state.copyWith(
          status: GoalFormStatus.ready,
          errorText: failureText(f),
        ),
        (_) => state.copyWith(status: GoalFormStatus.deleted),
      ),
    );
  }

  Future<void> _write(
    Emitter<GoalFormState> emit,
    Future<Either<Failure, Object>> Function() action,
    GoalFormStatus done,
  ) async {
    if (state.isBusy) return;
    emit(state.copyWith(status: GoalFormStatus.saving));
    final result = await action();
    emit(
      result.fold(
        // Back to ready so the filled form stays and can be saved again.
        (f) => state.copyWith(
          status: GoalFormStatus.ready,
          errorText: failureText(f),
        ),
        (_) => state.copyWith(status: done),
      ),
    );
  }
}
