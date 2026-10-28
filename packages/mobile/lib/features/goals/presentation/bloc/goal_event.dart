import 'package:equatable/equatable.dart';

sealed class GoalEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const GoalEvent();
}

class GoalWatchStarted extends GoalEvent {
  const GoalWatchStarted();
}

class GoalContributionSubmitted extends GoalEvent {
  final String goalId;
  final double amount;

  @override
  List<Object?> get props => [goalId, amount];

  const GoalContributionSubmitted({required this.goalId, required this.amount});
}
