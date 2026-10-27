import 'package:equatable/equatable.dart';

import '../../domain/entities/goal.dart';

enum GoalStatus { loading, ready, saving, error }

class GoalState extends Equatable {
  /// Every goal, newest first.
  final List<Goal> goals;
  final GoalStatus status;
  final String? errorText;
  final double? lastAdded;

  /// The goal the last contribution went to.
  final Goal? lastAddedTo;

  final int contributionCount;

  /// The goal the dashboard card shows.
  Goal? get newest => goals.isEmpty ? null : goals.first;

  @override
  List<Object?> get props => [
    goals,
    status,
    errorText,
    lastAdded,
    lastAddedTo,
    contributionCount,
  ];

  const GoalState({
    this.goals = const [],
    this.status = GoalStatus.loading,
    this.errorText,
    this.lastAdded,
    this.lastAddedTo,
    this.contributionCount = 0,
  });

  GoalState copyWith({
    List<Goal>? goals,
    GoalStatus? status,
    String? errorText,
    double? lastAdded,
    Goal? lastAddedTo,
    int? contributionCount,
  }) {
    return GoalState(
      goals: goals ?? this.goals,
      status: status ?? this.status,
      errorText: errorText,
      lastAdded: lastAdded ?? this.lastAdded,
      lastAddedTo: lastAddedTo ?? this.lastAddedTo,
      contributionCount: contributionCount ?? this.contributionCount,
    );
  }
}
