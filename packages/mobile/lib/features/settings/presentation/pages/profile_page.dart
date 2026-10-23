import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/features/auth/domain/entities/user.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/helpers/user_display.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/google_logo.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/user_avatar.dart';
import 'package:expense_tracker/features/data_wipe/presentation/helpers/refresh_after_local_wipe.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';

import '../bloc/delete_account_bloc.dart';
import '../bloc/delete_account_event.dart';
import '../bloc/delete_account_state.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import 'delete_account_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Pushed above the app shell, so it needs its own themed Scaffold.
    return BlocProvider(
      create: (_) => di.getIt<DeleteAccountBloc>(),
      child: const Scaffold(body: ProfileView()),
    );
  }
}

/// My profile: the Google account read-only, Sign out and Delete account.
/// Name and photo come from Google, so nothing here is editable.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  bool _isOutcome(DeleteAccountState previous, DeleteAccountState current) =>
      current.status != previous.status &&
      (current.status == DeleteAccountStatus.deleted ||
          current.status == DeleteAccountStatus.failed);

  void _onDeleteAccountState(BuildContext context, DeleteAccountState state) {
    // Captured first: the refresh leaves this page.
    final messenger = ScaffoldMessenger.of(context);
    if (state.status == DeleteAccountStatus.deleted) {
      context.read<AuthBloc>().add(const SignOutRequested());
      refreshAfterLocalWipe(context);
    }
    final message = state.status == DeleteAccountStatus.deleted
        ? t.settings.profile.accountDeleted
        : state.errorMessage;
    if (message == null) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildBody(BuildContext context, DeleteAccountState deleteState) {
    final authState = context.watch<AuthBloc>().state;
    final deleting = deleteState.status == DeleteAccountStatus.deleting;

    // Leaving mid-delete is blocked: no back button, and system back is off.
    return PopScope(
      canPop: !deleting,
      child: AppScaffold(
        title: t.settings.profile.title,
        leading: deleting ? null : const AppBackButton(),
        child: switch (authState) {
          Authenticated(:final user) => _SignedInContent(
            user: user,
            deleting: deleting,
          ),
          AuthLoading() => const Center(child: CircularProgressIndicator()),
          _ => const _SignedOutContent(),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeleteAccountBloc, DeleteAccountState>(
      listenWhen: _isOutcome,
      listener: _onDeleteAccountState,
      builder: _buildBody,
    );
  }
}

class _SignedInContent extends StatelessWidget {
  final User user;
  final bool deleting;

  const _SignedInContent({required this.user, required this.deleting});

  void _onSignOut(BuildContext context) {
    context.read<AuthBloc>().add(const SignOutRequested());
    context.go(AppRootTab.home.location);
  }

  void _onDeleteAccountTap(BuildContext context) {
    final bloc = context.read<DeleteAccountBloc>();
    showDialog<void>(
      context: context,
      builder: (_) => DeleteAccountDialog(
        onConfirm: () => bloc.add(const DeleteAccountRequested()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsT = t.settings;
    final profileT = settingsT.profile;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final errorColor = Theme.of(context).colorScheme.error;
    final noteStyle = textTheme.bodySmall?.copyWith(
      color: palette.textSecondary,
    );

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        _ProfileHeader(user: user),
        if (deleting) ...[
          const SizedBox(height: AppSpacing.md),
          const LinearProgressIndicator(),
          const SizedBox(height: AppSpacing.sm),
          Text(
            profileT.deletingAccount,
            textAlign: TextAlign.center,
            style: noteStyle,
          ),
        ],
        _AccountCard(user: user),
        const SizedBox(height: AppSpacing.sm),
        Text(profileT.googleNote, style: noteStyle),
        IgnorePointer(
          ignoring: deleting,
          child: Opacity(
            opacity: deleting ? 0.5 : 1,
            child: SettingsSection(
              title: null,
              children: [
                SettingsTile(
                  icon: PiconsRegular.signOut,
                  title: settingsT.signOut,
                  titleColor: errorColor,
                  onTap: () => _onSignOut(context),
                ),
                SettingsTile(
                  icon: PiconsRegular.trash,
                  title: settingsT.deleteAccount,
                  titleColor: errorColor,
                  onTap: () => _onDeleteAccountTap(context),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

/// Avatar, name, email and the "Signed in with Google" mark.
class _ProfileHeader extends StatelessWidget {
  final User user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final email = user.email;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        UserAvatar(user: user, radius: 40),
        const SizedBox(height: AppSpacing.smd),
        Text(
          userDisplayName(user),
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
        if (email != null && email.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            email,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GoogleLogo(size: AppSpacing.iconSm),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                t.settings.profile.signedInWith,
                style: textTheme.bodySmall?.copyWith(
                  color: palette.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Name and email as read-only rows: no arrow, no tap.
class _AccountCard extends StatelessWidget {
  final User user;

  const _AccountCard({required this.user});

  Widget _row(BuildContext context, {required String label, String? value}) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      title: Text(
        label,
        style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
      ),
      subtitle: Text(
        value ?? '',
        style: textTheme.bodyMedium?.copyWith(color: palette.textPrimary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileT = t.settings.profile;
    final name = (user.displayName ?? '').trim();

    return SettingsSection(
      title: null,
      children: [
        _row(
          context,
          label: profileT.nameLabel,
          value: name.isEmpty ? profileT.noName : name,
        ),
        _row(context, label: profileT.emailLabel, value: user.email),
      ],
    );
  }
}

/// Shown when the page is opened signed out, or after signing out here.
class _SignedOutContent extends StatelessWidget {
  const _SignedOutContent();

  @override
  Widget build(BuildContext context) {
    final profileT = t.settings.profile;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        const SizedBox(height: AppSpacing.xl),
        const Center(child: UserAvatar(user: null, radius: 40)),
        const SizedBox(height: AppSpacing.md),
        Text(
          profileT.signedOutTitle,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          profileT.signedOutBody,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: ElevatedButton(
            onPressed: () => context.push('/login'),
            child: Text(t.settings.signIn.title),
          ),
        ),
      ],
    );
  }
}
