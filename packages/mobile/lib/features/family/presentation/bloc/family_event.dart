import 'package:equatable/equatable.dart';

import '../../domain/entities/group_role.dart';

sealed class FamilyEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const FamilyEvent();
}

/// Opens a Family screen: the cached group first when [preferCache], then
/// `/groups/me` and the summary.
class FamilyLoadRequested extends FamilyEvent {
  final bool preferCache;

  @override
  List<Object?> get props => [preferCache];

  const FamilyLoadRequested({this.preferCache = true});
}

/// Pull to refresh: always asks the server.
class FamilyRefreshRequested extends FamilyEvent {
  const FamilyRefreshRequested();
}

class FamilyCreateRequested extends FamilyEvent {
  final String name;
  final double? monthlyBudget;

  @override
  List<Object?> get props => [name, monthlyBudget];

  const FamilyCreateRequested({required this.name, this.monthlyBudget});
}

class FamilyJoinRequested extends FamilyEvent {
  final String code;

  @override
  List<Object?> get props => [code];

  const FamilyJoinRequested(this.code);
}

/// Shows the active Invite Code, making one only when there is none; with
/// [regenerate] a new code replaces the old.
class FamilyInviteRequested extends FamilyEvent {
  final bool regenerate;

  @override
  List<Object?> get props => [regenerate];

  const FamilyInviteRequested({this.regenerate = false});
}

class FamilyRoleChangeRequested extends FamilyEvent {
  final String userId;
  final GroupRole role;

  @override
  List<Object?> get props => [userId, role];

  const FamilyRoleChangeRequested({required this.userId, required this.role});
}

class FamilyMemberRemoveRequested extends FamilyEvent {
  final String userId;

  @override
  List<Object?> get props => [userId];

  const FamilyMemberRemoveRequested(this.userId);
}

class FamilyLeaveRequested extends FamilyEvent {
  const FamilyLeaveRequested();
}

class FamilyDeleteRequested extends FamilyEvent {
  const FamilyDeleteRequested();
}

/// The screen has shown [FamilyState.failure].
class FamilyFailureCleared extends FamilyEvent {
  const FamilyFailureCleared();
}
