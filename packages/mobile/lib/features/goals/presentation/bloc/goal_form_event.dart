import 'package:equatable/equatable.dart';

import '../../domain/entities/goal.dart';

sealed class GoalFormEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const GoalFormEvent();
}

/// Edit mode: load the goal with [id].
class GoalFormLoaded extends GoalFormEvent {
  final String id;

  @override
  List<Object?> get props => [id];

  const GoalFormLoaded(this.id);
}

/// Create mode (Task 22b): an empty form.
class GoalFormStartedNew extends GoalFormEvent {
  const GoalFormStartedNew();
}

class GoalFormSaved extends GoalFormEvent {
  final Goal goal;

  @override
  List<Object?> get props => [goal];

  const GoalFormSaved(this.goal);
}

class GoalFormCreated extends GoalFormEvent {
  final Goal goal;

  @override
  List<Object?> get props => [goal];

  const GoalFormCreated(this.goal);
}

class GoalFormDeleted extends GoalFormEvent {
  const GoalFormDeleted();
}
