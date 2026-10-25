import 'package:equatable/equatable.dart';

import 'group_role.dart';
import 'invite_code.dart';

class FamilyGroup extends Equatable {
  final String id;
  final String name;
  final String currencyCode;
  final double? monthlyBudget;

  @override
  List<Object?> get props => [id, name, currencyCode, monthlyBudget];

  const FamilyGroup({
    required this.id,
    required this.name,
    required this.currencyCode,
    this.monthlyBudget,
  });
}

class GroupMember extends Equatable {
  /// The server user id (not the Firebase uid).
  final String userId;
  final String? displayName;
  final String? photoUrl;
  final GroupRole role;
  final DateTime joinedAt;

  @override
  List<Object?> get props => [userId, displayName, photoUrl, role, joinedAt];

  const GroupMember({
    required this.userId,
    this.displayName,
    this.photoUrl,
    required this.role,
    required this.joinedAt,
  });

  // copyWith: null keeps the current role.
  // ignore: unnecessary-nullable
  GroupMember copyWith({GroupRole? role}) => GroupMember(
    userId: userId,
    displayName: displayName,
    photoUrl: photoUrl,
    role: role ?? this.role,
    joinedAt: joinedAt,
  );
}

/// A budget shared into the group, and who owns it.
class SharedBudgetRef extends Equatable {
  final String id;
  final String name;
  final String ownerId;

  @override
  List<Object?> get props => [id, name, ownerId];

  const SharedBudgetRef({
    required this.id,
    required this.name,
    required this.ownerId,
  });
}

/// The signed-in user's Family Group, from `GET /groups/me`. "Not in a
/// group" is a null `MyGroup?`, never an empty object.
class MyGroup extends Equatable {
  final FamilyGroup group;

  /// The caller's server user id; the phone only knows its Firebase uid.
  final String myUserId;
  final GroupRole myRole;

  /// Oldest member first; avatar colours follow this order.
  final List<GroupMember> members;
  final List<SharedBudgetRef> sharedBudgets;

  /// The active Invite Code, for Admins only.
  final InviteCode? invite;

  @override
  List<Object?> get props => [
    group,
    myUserId,
    myRole,
    members,
    sharedBudgets,
    invite,
  ];

  const MyGroup({
    required this.group,
    required this.myUserId,
    required this.myRole,
    required this.members,
    required this.sharedBudgets,
    this.invite,
  });

  bool listsBudget(String budgetId) =>
      sharedBudgets.any((budget) => budget.id == budgetId);

  bool ownsBudget(String budgetId) => sharedBudgets.any(
    (budget) => budget.id == budgetId && budget.ownerId == myUserId,
  );

  MyGroup copyWith({
    List<GroupMember>? members,
    GroupRole? myRole,
    InviteCode? invite,
  }) => MyGroup(
    group: group,
    myUserId: myUserId,
    myRole: myRole ?? this.myRole,
    members: members ?? this.members,
    sharedBudgets: sharedBudgets,
    invite: invite ?? this.invite,
  );
}
