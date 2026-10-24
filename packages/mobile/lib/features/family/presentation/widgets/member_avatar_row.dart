import 'package:expense_tracker/core/router/family_route.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';

import '../../domain/entities/my_group.dart';
import '../helpers/family_dashboard_helpers.dart';
import 'member_avatar.dart';

/// Up to five member avatars, then "+N"; Admins also get "+" to invite.
class MemberAvatarRow extends StatelessWidget {
  final MyGroup group;

  const MemberAvatarRow({super.key, required this.group});

  void _openInvite(BuildContext context) =>
      context.push(FamilyRoute.invite.location);

  Widget _circle(BuildContext context, Widget child) => CircleAvatar(
    radius: 20,
    backgroundColor: context.palette.surfaceHigh,
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final slice = avatarSlice(group.members);
    final textTheme = Theme.of(context).textTheme;
    final more = slice.more;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (index, member) in slice.shown.indexed)
          Semantics(
            label: memberLabel(
              userId: member.userId,
              displayName: member.displayName,
              myUserId: group.myUserId,
            ),
            child: MemberAvatar(
              displayName: member.displayName,
              photoUrl: member.photoUrl,
              index: index,
            ),
          ),
        if (more > 0)
          _circle(
            context,
            Text(
              t.family.dashboard.moreMembers(n: more),
              style: textTheme.labelMedium,
            ),
          ),
        if (group.myRole.isAdmin)
          Semantics(
            button: true,
            label: t.family.invite.title,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _openInvite(context),
              child: _circle(
                context,
                Icon(PiconsRegular.userPlus, color: context.palette.accent),
              ),
            ),
          ),
      ],
    );
  }
}
