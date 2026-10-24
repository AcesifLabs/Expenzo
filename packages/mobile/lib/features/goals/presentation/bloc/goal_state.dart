import 'package:equatable/equatable.dart';

import '../../domain/entities/goal.dart';

enum GoalStatus { loading, ready, saving, error }

class GoalState extends Equatable {
  final Goal? goal;
  final GoalStatus status;
  final String? errorText;
  final double? lastAdded;

  /// Goes up on each saved contribution, so a listener fires even when the
  /// same amount is added twice.
  final int contributionCount;

  @override
  List<Object?> get props => [
    goal,
    status,
    errorText,
    lastAdded,
    contributionCount,
  ];

  const GoalState({
    this.goal,
    this.status = GoalStatus.loading,
    this.errorText,
    this.lastAdded,
    this.contributionCount = 0,
  });

  /// [goal] can be cleared with [clearGoal]; [errorText] is cleared unless
  /// given.
  GoalState copyWith({
    Goal? goal,
    bool clearGoal = false,
    GoalStatus? status,
    String? errorText,
    double? lastAdded,
    int? contributionCount,
  }) {
    return GoalState(
      goal: clearGoal ? null : goal ?? this.goal,
      status: status ?? this.status,
      errorText: errorText,
      lastAdded: lastAdded ?? this.lastAdded,
      contributionCount: contributionCount ?? this.contributionCount,
    );
  }
}
