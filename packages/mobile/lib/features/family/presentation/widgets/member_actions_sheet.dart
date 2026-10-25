import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_choice_tile.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

import '../../domain/entities/group_role.dart';
import '../../domain/entities/my_group.dart';
import '../helpers/member_actions.dart';

/// What the Admin decided in [showMemberActionsSheet].
sealed class MemberDecision {
  const MemberDecision();
}

class MemberRoleChosen extends MemberDecision {
  final GroupRole role;

  const MemberRoleChosen(this.role);
}

class MemberRemoveConfirmed extends MemberDecision {
  const MemberRemoveConfirmed();
}

/// The Admin's actions on one member: change role (check-mark choices,
/// never radio buttons) or remove from the group, after asking. Null when
/// the Admin backs out or picks the role the member already has.
Future<MemberDecision?> showMemberActionsSheet(
  BuildContext context, {
  required GroupMember member,
  required String memberName,
  required List<MemberAction> actions,
}) async {
  final surface = context.palette.surface;
  final action = await showModalBottomSheet<MemberAction>(
    context: context,
    backgroundColor: surface,
    builder: (sheetContext) => _ActionList(actions: actions),
  );
  if (!context.mounted) return null;
  switch (action) {
    case MemberAction.changeRole:
      final role = await showModalBottomSheet<GroupRole>(
        context: context,
        backgroundColor: surface,
        builder: (sheetContext) => _RoleChoices(current: member.role),
      );

      return role == null || role == member.role
          ? null
          : MemberRoleChosen(role);
    case MemberAction.remove:
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => _RemoveDialog(name: memberName),
      );

      return confirmed == true ? const MemberRemoveConfirmed() : null;
    case null:
      return null;
  }
}

class _ActionList extends StatelessWidget {
  final List<MemberAction> actions;

  const _ActionList({required this.actions});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final membersT = t.family.members;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (actions.contains(MemberAction.changeRole))
              ListTile(
                leading: Icon(
                  PiconsRegular.userSwitch,
                  color: palette.textPrimary,
                ),
                title: Text(membersT.changeRole),
                onTap: () => Navigator.pop(context, MemberAction.changeRole),
              ),
            if (actions.contains(MemberAction.remove))
              ListTile(
                leading: Icon(PiconsRegular.userMinus, color: palette.expense),
                title: Text(
                  membersT.remove,
                  style: TextStyle(color: palette.expense),
                ),
                onTap: () => Navigator.pop(context, MemberAction.remove),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoleChoices extends StatelessWidget {
  final GroupRole current;

  const _RoleChoices({required this.current});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final role in GroupRole.values)
              SettingsChoiceTile(
                title: roleName(role),
                subtitle: roleHint(role),
                selected: role == current,
                onTap: () => Navigator.pop(context, role),
              ),
          ],
        ),
      ),
    );
  }
}

class _RemoveDialog extends StatelessWidget {
  final String name;

  const _RemoveDialog({required this.name});

  @override
  Widget build(BuildContext context) {
    final membersT = t.family.members;

    return AlertDialog(
      title: Text(membersT.removeTitle(name: name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(t.common.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            membersT.remove,
            style: TextStyle(color: context.palette.expense),
          ),
        ),
      ],
    );
  }
}
