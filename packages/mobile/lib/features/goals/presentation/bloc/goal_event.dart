import 'package:equatable/equatable.dart';

sealed class GoalEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const GoalEvent();
}

/// Follows the active goal (a goal pulled from another device included).
class GoalWatchStarted extends GoalEvent {
  const GoalWatchStarted();
}

/// "Add to goal" with [amount]. Creates no Record (ADR 0009).
class GoalContributionSubmitted extends GoalEvent {
  final double amount;

  @override
  List<Object?> get props => [amount];

  const GoalContributionSubmitted(this.amount);
}
