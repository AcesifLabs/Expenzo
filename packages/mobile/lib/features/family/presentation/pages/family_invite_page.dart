import 'dart:async';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/router/settings_route.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/presentation/widgets/shimmer_box.dart';
import 'package:expense_tracker/shared/services/file_share_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';

import '../../domain/entities/invite_code.dart';
import '../bloc/family_bloc.dart';
import '../bloc/family_event.dart';
import '../bloc/family_state.dart';
import '../helpers/family_failure_listener.dart';
import '../helpers/invite_share_text.dart';
import '../widgets/family_icon_header.dart';

/// Frame `FamilyInviteMembers`: the Admin's current Invite Code, shared as
/// text (no QR code, ADR 0011), or regenerated.
class FamilyInvitePage extends StatefulWidget {
  /// The time now, replaced in tests.
  final DateTime Function() clock;

  const FamilyInvitePage({super.key, this.clock = DateTime.now});

  @override
  State<FamilyInvitePage> createState() => _FamilyInvitePageState();
}

class _FamilyInvitePageState extends State<FamilyInvitePage> {
  /// Asking for a code failed (offline) and nothing valid is cached.
  var _failed = false;

  String get _locale => LocaleSettings.currentLocale.languageCode;

  FileShareService get _shareService =>
      di.getIt.isRegistered<FileShareService>()
      ? di.getIt<FileShareService>()
      : const FileShareService();

  bool _groupArrived(FamilyState previous, FamilyState current) =>
      previous.myGroup == null && current.myGroup != null;

  /// Only Admins may invite; the bloc reuses a live code before making one.
  void _onGroup(BuildContext context, FamilyState state) {
    if (!(state.myGroup?.myRole.isAdmin ?? false)) {
      context.pop();

      return;
    }
    context.read<FamilyBloc>().add(const FamilyInviteRequested());
  }

  void _onFailure(BuildContext context, FamilyState state) {
    if (state.activeInviteAt(widget.clock()) == null) {
      setState(() => _failed = true);
    }
    handleFamilyState(context, state);
  }

  void _retry() {
    setState(() => _failed = false);
    context.read<FamilyBloc>().add(const FamilyInviteRequested());
  }

  void _onCopy(InviteCode invite) {
    unawaited(Clipboard.setData(ClipboardData(text: invite.code)));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(t.family.invite.copied)));
  }

  void _onShare(String groupName, InviteCode invite) {
    unawaited(
      _shareService.shareText(
        buildInviteShareText(
          groupName: groupName,
          invite: invite,
          locale: _locale,
        ),
      ),
    );
  }

  void _onRegenerate() => unawaited(_confirmRegenerate());

  Future<void> _confirmRegenerate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: _buildRegenerateDialog,
    );
    if (confirmed != true || !mounted) return;
    context.read<FamilyBloc>().add(
      const FamilyInviteRequested(regenerate: true),
    );
  }

  Widget _buildRegenerateDialog(BuildContext dialogContext) {
    final inviteT = t.family.invite;

    return AlertDialog(
      title: Text(inviteT.regenerateTitle),
      content: Text(inviteT.regenerateBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(t.common.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(inviteT.regenerate),
        ),
      ],
    );
  }

  void _onDone() => context.go(SettingsRoute.family.location);

  Widget _buildBody(BuildContext context, FamilyState state) {
    final inviteT = t.family.invite;
    final invite = state.activeInviteAt(widget.clock());
    final groupName = state.myGroup?.group.name ?? '';
    final canAct = invite != null && !state.busy;

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        FamilyIconHeader(
          icon: PiconsRegular.userPlus,
          heading: inviteT.heading,
          body: inviteT.limitNote,
        ),
        _buildCodeCard(context, state, invite),
        const SizedBox(height: AppSpacing.lg),
        ConstrainedBox(
          // Grows with the label at large text sizes.
          constraints: const BoxConstraints(
            minWidth: double.infinity,
            minHeight: AppSpacing.xxl,
          ),
          child: ElevatedButton.icon(
            icon: const Icon(PiconsRegular.shareNetwork),
            label: Text(inviteT.share),
            onPressed: canAct ? () => _onShare(groupName, invite) : null,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, AppSpacing.minTapTarget),
            ),
            onPressed: canAct ? _onRegenerate : null,
            child: Text(inviteT.regenerate),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ConstrainedBox(
          // Grows with the label at large text sizes.
          constraints: const BoxConstraints(
            minWidth: double.infinity,
            minHeight: AppSpacing.xxl,
          ),
          child: OutlinedButton(onPressed: _onDone, child: Text(t.common.done)),
        ),
      ],
    );
  }

  Widget _buildCodeCard(
    BuildContext context,
    FamilyState state,
    InviteCode? invite,
  ) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final inviteT = t.family.invite;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.surfaceHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Column(
        children: [
          Text(
            inviteT.codeCaption,
            style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: AppSpacing.smd),
          _buildCode(context, state, invite),
        ],
      ),
    );
  }

  Widget _buildCode(
    BuildContext context,
    FamilyState state,
    InviteCode? invite,
  ) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final inviteT = t.family.invite;
    if (invite != null && !state.busy) {
      return InkWell(
        onTap: () => _onCopy(invite),
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        child: Column(
          children: [
            Text(
              invite.code,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: AppSpacing.sm,
                fontFeatures: AppTypography.tabularFigures,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              inviteT.validUntil(
                time: formatInviteExpiry(invite.expiresAt, _locale),
              ),
              style: textTheme.bodySmall?.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    if (_failed && !state.busy) {
      final hadCode = (state.invite ?? state.myGroup?.invite) != null;

      return Column(
        children: [
          Text(
            hadCode ? inviteT.expired : inviteT.offline,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
          TextButton(onPressed: _retry, child: Text(t.common.tryAgain)),
        ],
      );
    }

    return state.busy
        ? const Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: CircularProgressIndicator(),
          )
        : ShimmerBox(
            child: ShimmerBox.rectangle(
              width: AppSpacing.xxl * 4,
              height: AppSpacing.xl,
              borderRadius: AppSpacing.radiusControl,
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final inviteT = t.family.invite;

    return MultiBlocListener(
      listeners: [
        BlocListener<FamilyBloc, FamilyState>(
          listenWhen: _groupArrived,
          listener: _onGroup,
        ),
        BlocListener<FamilyBloc, FamilyState>(
          listenWhen: familyStateNeedsListener,
          listener: _onFailure,
        ),
      ],
      child: Scaffold(
        body: AppScaffold(
          title: inviteT.title,
          leading: const AppBackButton(),
          child: BlocBuilder<FamilyBloc, FamilyState>(
            builder: (context, state) => _buildBody(context, state),
          ),
        ),
      ),
    );
  }
}
