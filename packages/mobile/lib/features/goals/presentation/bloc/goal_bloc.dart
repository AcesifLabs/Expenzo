import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';

import '../../domain/usecases/add_goal_contribution.dart';
import '../../domain/usecases/watch_goals.dart';
import 'goal_event.dart';
import 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final WatchGoals watchGoals;
  final AddGoalContribution addGoalContribution;

  GoalBloc({required this.watchGoals, required this.addGoalContribution})
    : super(const GoalState()) {
    on<GoalWatchStarted>(_onWatch, transformer: restartable());
    on<GoalContributionSubmitted>(_onContribution, transformer: droppable());
  }

  Future<void> _onWatch(GoalWatchStarted event, Emitter<GoalState> emit) {
    return emit.forEach(
      watchGoals(),
      onData: (goals) => state.copyWith(
        goals: goals,
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
    if (state.status == GoalStatus.saving) return;
    emit(state.copyWith(status: GoalStatus.saving));
    final result = await addGoalContribution(
      AddGoalContributionParams(goalId: event.goalId, amount: event.amount),
    );
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: GoalStatus.ready,
          errorText: failureText(failure),
        ),

        (goal) => state.copyWith(
          status: GoalStatus.ready,
          lastAdded: event.amount,
          lastAddedTo: goal,
          contributionCount: state.contributionCount + 1,
        ),
      ),
    );
  }
}
