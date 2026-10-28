import 'package:equatable/equatable.dart';

import '../../domain/entities/goal.dart';

enum GoalFormStatus {
  loading,
  ready,
  saving,
  saved,
  created,
  deleting,
  deleted,
  notFound,
  failure,
}

class GoalFormState extends Equatable {
  final Goal? goal;
  final GoalFormStatus status;
  final String? errorText;

  bool get isBusy =>
      status == GoalFormStatus.saving || status == GoalFormStatus.deleting;

  @override
  List<Object?> get props => [goal, status, errorText];

  const GoalFormState({
    this.goal,
    this.status = GoalFormStatus.loading,
    this.errorText,
  });

  GoalFormState copyWith({
    Goal? goal,
    GoalFormStatus? status,
    String? errorText,
  }) {
    return GoalFormState(
      goal: goal ?? this.goal,
      status: status ?? this.status,
      errorText: errorText,
    );
  }
}
