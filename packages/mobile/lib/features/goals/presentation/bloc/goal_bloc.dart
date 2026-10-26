import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';

import '../../domain/usecases/add_goal_contribution.dart';
import '../../domain/usecases/watch_active_goal.dart';
import 'goal_event.dart';
import 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final WatchActiveGoal watchActiveGoal;
  final AddGoalContribution addGoalContribution;

  GoalBloc({required this.watchActiveGoal, required this.addGoalContribution})
    : super(const GoalState()) {
    on<GoalWatchStarted>(_onWatch, transformer: restartable());
    on<GoalContributionSubmitted>(_onContribution, transformer: droppable());
  }

  Future<void> _onWatch(GoalWatchStarted event, Emitter<GoalState> emit) {
    return emit.forEach(
      watchActiveGoal(),
      onData: (goal) => state.copyWith(
        goal: goal,
        clearGoal: goal == null,
        status: state.status == GoalStatus.saving
            ? GoalStatus.saving
            : GoalStatus.ready,
      ),
      onError: (e, s) {
        appLogger.error('Goal stream failed', e, s);

        return state.copyWith(status: GoalStatus.error);
      },
    );
  }

  Future<void> _onContribution(
    GoalContributionSubmitted event,
    Emitter<GoalState> emit,
  ) async {
    final goalId = state.goal?.id;
    if (goalId == null || state.status == GoalStatus.saving) return;
    emit(state.copyWith(status: GoalStatus.saving));
    final result = await addGoalContribution(
      AddGoalContributionParams(goalId: goalId, amount: event.amount),
    );
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: GoalStatus.ready,
          errorText: failureText(failure),
        ),

        (_) => state.copyWith(
          status: GoalStatus.ready,
          lastAdded: event.amount,
          contributionCount: state.contributionCount + 1,
        ),
      ),
    );
  }
}
