import 'dart:async';

import 'package:expense_tracker/core/router/family_route.dart';
import 'package:expense_tracker/core/router/settings_route.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_empty_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/presentation/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';

import '../../domain/entities/my_group.dart';
import '../bloc/family_bloc.dart';
import '../bloc/family_event.dart';
import '../bloc/family_state.dart';
import '../helpers/family_dashboard_helpers.dart';
import '../helpers/family_failure_listener.dart';
import '../helpers/member_actions.dart';
import '../widgets/member_actions_sheet.dart';
import '../widgets/member_avatar.dart';
import '../widgets/role_badge.dart';

/// Frame `FamilyMemberManagement`: members and their roles. Admins change
/// roles, remove members, invite more and delete the group; everyone can
/// leave.
class FamilyMembersPage extends StatelessWidget {
  const FamilyMembersPage({super.key});

  bool _membershipEnded(FamilyState previous, FamilyState current) {
    const ended = {FamilyAction.left, FamilyAction.deleted};

    return ended.contains(current.lastAction) &&
        previous.lastAction != current.lastAction;
  }

  void _onMembershipEnded(BuildContext context, FamilyState _) =>
      context.go(SettingsRoute.rootLocation);

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FamilyBloc, FamilyState>(
          listenWhen: familyStateNeedsListener,
          listener: handleFamilyState,
        ),
        BlocListener<FamilyBloc, FamilyState>(
          listenWhen: _membershipEnded,
          listener: _onMembershipEnded,
        ),
      ],
      child: BlocBuilder<FamilyBloc, FamilyState>(
        builder: (context, state) {
          final group = state.myGroup;

          return Scaffold(
            body: AppScaffold(
              title: t.family.members.title(count: group?.members.length ?? 0),
              leading: const AppBackButton(),
              child: switch (group) {
                final group? => _MembersBody(group: group, busy: state.busy),
                null when state.status == FamilyStatus.failure => AppEmptyState(
                  icon: PiconsRegular.warning,
                  message: t.family.dashboard.loadFailed,
                  actionLabel: t.common.tryAgain,
                  onAction: () => context.read<FamilyBloc>().add(
                    const FamilyRefreshRequested(),
                  ),
                ),
                null => const _MembersLoading(),
              },
            ),
          );
        },
      ),
    );
  }
}

class _MembersBody extends StatelessWidget {
  final MyGroup group;
  final bool busy;

  const _MembersBody({required this.group, required this.busy});

  String _name(GroupMember member) => memberLabel(
    userId: member.userId,
    displayName: member.displayName,
    myUserId: group.myUserId,
  );

  void _openActions(BuildContext context, GroupMember member) =>
      unawaited(_runActions(context, member));

  Future<void> _runActions(BuildContext context, GroupMember member) async {
    final bloc = context.read<FamilyBloc>();
    final decision = await showMemberActionsSheet(
      context,
      member: member,
      memberName: _name(member),
      actions: actionsFor(group: group, target: member),
    );
    switch (decision) {
      case MemberRoleChosen(:final role):
        bloc.add(FamilyRoleChangeRequested(userId: member.userId, role: role));
      case MemberRemoveConfirmed():
        bloc.add(FamilyMemberRemoveRequested(member.userId));
      case null:
        break;
    }
  }

  void _confirmLeave(BuildContext context) {
    final membersT = t.family.members;
    unawaited(
      _confirm(
        context,
        copy: (
          title: membersT.leaveTitle(name: group.group.name),
          body: isLastMember(group)
              ? membersT.leaveLastBody
              : membersT.leaveBody,
          action: membersT.leave,
        ),
        event: const FamilyLeaveRequested(),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final membersT = t.family.members;
    unawaited(
      _confirm(
        context,
        copy: (
          title: membersT.deleteTitle(name: group.group.name),
          body: membersT.deleteBody,
          action: membersT.deleteGroup,
        ),
        event: const FamilyDeleteRequested(),
      ),
    );
  }

  /// Asks with [copy] and sends [event] when the user confirms.
  Future<void> _confirm(
    BuildContext context, {
    required ({String title, String body, String action}) copy,
    required FamilyEvent event,
  }) async {
    final (:title, :body, :action) = copy;
    final bloc = context.read<FamilyBloc>();
    final expense = context.palette.expense;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(action, style: TextStyle(color: expense)),
          ),
        ],
      ),
    );
    if (confirmed == true) bloc.add(event);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final membersT = t.family.members;
    final isAdmin = group.myRole.isAdmin;
    final destructive = TextButton.styleFrom(
      foregroundColor: palette.expense,
      minimumSize: const Size(0, AppSpacing.minTapTarget),
    );

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        const SizedBox(height: AppSpacing.sm),
        _MemberCard(
          group: group,
          busy: busy,
          name: _name,
          onTap: (member) => _openActions(context, member),
        ),
        if (isAdmin) ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            icon: const Icon(PiconsRegular.userPlus),
            label: Text(membersT.inviteMore),
            onPressed: busy
                ? null
                : () => context.push(FamilyRoute.invite.location),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        TextButton(
          style: destructive,
          onPressed: busy ? null : () => _confirmLeave(context),
          child: Text(membersT.leave),
        ),
        if (isAdmin)
          TextButton(
            style: destructive,
            onPressed: busy ? null : () => _confirmDelete(context),
            child: Text(membersT.deleteGroup),
          ),
      ],
    );
  }
}

/// The members in one card, oldest first, with dividers.
class _MemberCard extends StatelessWidget {
  final MyGroup group;
  final bool busy;
  final String Function(GroupMember) name;
  final ValueChanged<GroupMember> onTap;

  const _MemberCard({
    required this.group,
    required this.busy,
    required this.name,
    required this.onTap,
  });

  Widget _row(
    int index,
    GroupMember member,
    TextTheme textTheme,
    AppPalette palette,
  ) {
    final canAct = actionsFor(group: group, target: member).isNotEmpty;

    return ListTile(
      leading: MemberAvatar(
        displayName: member.displayName,
        photoUrl: member.photoUrl,
        index: index,
      ),
      title: Text(name(member), style: textTheme.bodyLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RoleBadge(role: member.role),
          if (canAct) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(PiconsRegular.caretRight, color: palette.textSecondary),
          ],
        ],
      ),
      onTap: canAct && !busy ? () => onTap(member) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: palette.surfaceHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (index, member) in group.members.indexed) ...[
            if (index > 0) Divider(height: 1, color: palette.divider),
            _row(index, member, textTheme, palette),
          ],
        ],
      ),
    );
  }
}

class _MembersLoading extends StatelessWidget {
  const _MembersLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: ShimmerBox(
              child: ShimmerBox.rectangle(
                width: double.infinity,
                height: 56,
                borderRadius: AppSpacing.radiusControl,
              ),
            ),
          ),
      ],
    );
  }
}
