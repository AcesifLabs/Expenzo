import 'package:expense_tracker/i18n/strings.g.dart';

import '../../domain/entities/group_role.dart';
import '../../domain/entities/my_group.dart';

enum MemberAction { changeRole, remove }

/// What the signed-in user may do to [target]: Admins change anyone's role
/// (their own included) and remove others; you leave instead of removing
/// yourself. Members and Viewers do nothing here.
List<MemberAction> actionsFor({
  required MyGroup group,
  required GroupMember target,
}) {
  if (!group.myRole.isAdmin) return const [];

  return [
    MemberAction.changeRole,
    if (target.userId != group.myUserId) MemberAction.remove,
  ];
}

/// Leaving as the last member deletes the group.
bool isLastMember(MyGroup group) => group.members.length == 1;

String roleName(GroupRole role) => switch (role) {
  GroupRole.admin => t.family.roles.admin,
  GroupRole.member => t.family.roles.member,
  GroupRole.viewer => t.family.roles.viewer,
};

String roleHint(GroupRole role) => switch (role) {
  GroupRole.admin => t.family.roleHints.admin,
  GroupRole.member => t.family.roleHints.member,
  GroupRole.viewer => t.family.roleHints.viewer,
};
