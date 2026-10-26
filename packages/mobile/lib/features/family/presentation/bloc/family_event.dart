import 'package:equatable/equatable.dart';

import '../../domain/entities/group_role.dart';

sealed class FamilyEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const FamilyEvent();
}

class FamilyLoadRequested extends FamilyEvent {
  final bool preferCache;

  @override
  List<Object?> get props => [preferCache];

  const FamilyLoadRequested({this.preferCache = true});
}

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

class FamilyFailureCleared extends FamilyEvent {
  const FamilyFailureCleared();
}
