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
  final double amount;

  @override
  List<Object?> get props => [amount];

  const GoalContributionSubmitted(this.amount);
}
