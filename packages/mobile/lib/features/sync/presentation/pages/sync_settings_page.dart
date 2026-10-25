import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/sync/sync_run_result.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_section.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_state_view.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_switch_tile.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';

import '../../domain/entities/sync_overview.dart';
import '../bloc/sync_screen_bloc.dart';
import '../bloc/sync_screen_event.dart';
import '../bloc/sync_screen_state.dart';
import '../helpers/last_sync_label.dart';

class SyncSettingsPage extends StatelessWidget {
  const SyncSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // The app-wide singleton; `create` would close it on pop.
        BlocProvider.value(value: di.getIt<SettingsBloc>()),
        BlocProvider(
          create: (_) =>
              di.getIt<SyncScreenBloc>()..add(const SyncScreenStarted()),
        ),
      ],
      child: const Scaffold(body: SyncSettingsView()),
    );
  }
}

/// Sync status for this device: whether it's on, the last sync, changes
/// waiting, the switch and "Sync now". The design's backup frequency is cut
/// (docs/adr/0011); the UI never says "backup".
class SyncSettingsView extends StatelessWidget {
  const SyncSettingsView({super.key});

  Widget _buildBody(BuildContext context, UserSettings settings) {
    final signedIn = context.watch<AuthBloc>().state is Authenticated;

    return BlocBuilder<SyncScreenBloc, SyncScreenState>(
      builder: (context, state) => ListView(
        padding: AppSpacing.pagePadding,
        children: signedIn
            ? _signedInChildren(context, settings, state)
            : const [_SignedOutCard()],
      ),
    );
  }

  List<Widget> _signedInChildren(
    BuildContext context,
    UserSettings settings,
    SyncScreenState state,
  ) {
    final overview = state.overview;
    if (state.loadStatus == SyncScreenLoadStatus.error) {
      return [_LoadFailed(onRetry: () => _onReload(context))];
    }
    if (overview == null) {
      return const [
        Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    final enabled = settings.syncEnabled;
    final canSync = enabled && !state.isSyncing;
    final syncT = t.settings.sync;

    return [
      if (overview.showFailureBanner) const _FailureBanner(),
      _StatusCard(enabled: enabled),
      SettingsSection(
        title: null,
        children: [
          _LastSyncRow(
            overview: overview,
            onRetry: canSync ? () => _onSyncNow(context) : null,
          ),
          _PendingRow(count: overview.pendingCount),
          if (state.failedCount > 0)
            _FailedRow(
              count: state.failedCount,
              onRetry: canSync ? () => _onRetryFailed(context) : null,
            ),
        ],
      ),
      SettingsSection(
        title: syncT.sections.device,
        children: [
          SettingsSwitchTile(
            icon: PiconsRegular.cloudArrowUp,
            title: syncT.enable,
            value: enabled,
            onChanged: (value) => _onEnabledChanged(context, enabled: value),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.lg),
      _SyncNowButton(
        isSyncing: state.isSyncing,
        onPressed: canSync ? () => _onSyncNow(context) : null,
      ),
      const SizedBox(height: AppSpacing.lg),
    ];
  }

  void _onReload(BuildContext context) {
    context.read<SyncScreenBloc>().add(const SyncScreenStarted());
  }

  void _onRetryFailed(BuildContext context) {
    context.read<SyncScreenBloc>().add(const FailedChangesRetryRequested());
  }

  void _onSyncNow(BuildContext context) {
    context.read<SyncScreenBloc>().add(const SyncNowRequested());
  }

  void _onEnabledChanged(BuildContext context, {required bool enabled}) {
    context.read<SettingsBloc>().add(UpdateSyncEnabled(enabled: enabled));
  }

  bool _authChanged(AuthState previous, AuthState current) =>
      (previous is Authenticated) != (current is Authenticated);

  void _onAuthChanged(BuildContext context, AuthState _) => _onReload(context);

  bool _newResult(SyncScreenState previous, SyncScreenState current) =>
      current.lastResult != null && current.lastResult != previous.lastResult;

  void _showResult(BuildContext context, SyncScreenState state) {
    final result = state.lastResult;
    if (result == null) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(_resultText(result))));
  }

  String _resultText(SyncRunResult result) {
    final resultT = t.settings.sync.result;

    return switch (result) {
      SyncRunResult.success => resultT.success,
      SyncRunResult.signedOut => resultT.signedOut,
      SyncRunResult.firstSyncPending => resultT.firstSyncPending,
      SyncRunResult.disabled => resultT.disabled,
      SyncRunResult.offline => resultT.offline,
      SyncRunResult.failed => resultT.failed,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: t.settings.sync.title,
      leading: const AppBackButton(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listenWhen: _authChanged,
            listener: _onAuthChanged,
          ),
          BlocListener<SyncScreenBloc, SyncScreenState>(
            listenWhen: _newResult,
            listener: _showResult,
          ),
        ],
        child: SettingsStateView(builder: _buildBody),
      ),
    );
  }
}

/// An icon beside a title and body, on a card.
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? background;
  final String title;
  final String body;
  final TextStyle? titleStyle;
  final TextStyle? bodyStyle;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    this.background,
    required this.title,
    required this.body,
    this.titleStyle,
    this.bodyStyle,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      backgroundColor: background ?? palette.surface,
      borderRadius: AppSpacing.radiusCard,
      padding: AppSpacing.paddingMd,
      margin: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle ?? textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
                  style:
                      bodyStyle ??
                      textTheme.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignedOutCard extends StatelessWidget {
  const _SignedOutCard();

  void _onSignIn(BuildContext context) => context.push('/login');

  @override
  Widget build(BuildContext context) {
    final syncT = t.settings.sync;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoCard(
          icon: PiconsRegular.cloudSlash,
          iconColor: context.palette.textSecondary,
          title: syncT.signedOutTitle,
          body: syncT.signedOutBody,
        ),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton(
          onPressed: () => _onSignIn(context),
          child: Text(t.settings.signIn.title),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool enabled;

  const _StatusCard({required this.enabled});

  @override
  Widget build(BuildContext context) {
    final syncT = t.settings.sync;
    final palette = context.palette;

    return enabled
        ? _InfoCard(
            icon: PiconsRegular.cloudCheck,
            iconColor: palette.brand,
            title: syncT.onTitle,
            body: syncT.onBody,
          )
        : _InfoCard(
            icon: PiconsRegular.cloudSlash,
            iconColor: palette.textSecondary,
            title: syncT.offTitle,
            body: syncT.offBody,
          );
  }
}

/// Shown after [SyncOverview.failureBannerThreshold] failed syncs in a row.
class _FailureBanner extends StatelessWidget {
  const _FailureBanner();

  @override
  Widget build(BuildContext context) {
    final syncT = t.settings.sync;
    final palette = context.palette;

    final textTheme = Theme.of(context).textTheme;

    return _InfoCard(
      icon: PiconsRegular.warning,
      iconColor: palette.warning,
      background: palette.warningTint,
      title: syncT.failureBannerTitle,
      body: syncT.failureBannerBody,
      titleStyle: textTheme.titleSmall,
      bodyStyle: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
    );
  }
}

class _LastSyncRow extends StatelessWidget {
  final SyncOverview overview;

  /// Null disables Retry (syncing, or Sync is off).
  final VoidCallback? onRetry;

  const _LastSyncRow({required this.overview, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final syncT = t.settings.sync;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final failedAt = overview.lastFailedSyncAt;
    final syncedAt = overview.lastSuccessfulSyncAt;

    if (overview.lastSyncFailed && failedAt != null) {
      return ListTile(
        title: Text(
          syncT.lastFailed(time: lastSyncLabel(failedAt, now)),
          style: textTheme.bodyLarge?.copyWith(color: palette.warning),
        ),
        trailing: TextButton(onPressed: onRetry, child: Text(syncT.retry)),
      );
    }

    return ListTile(
      title: Text(syncT.lastSynced, style: textTheme.bodyLarge),
      trailing: Text(
        syncedAt == null ? syncT.never : lastSyncLabel(syncedAt, now),
        style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
      ),
    );
  }
}

class _PendingRow extends StatelessWidget {
  final int count;

  const _PendingRow({required this.count});

  @override
  Widget build(BuildContext context) {
    final syncT = t.settings.sync;

    return ListTile(
      title: Text(
        count == 0 ? syncT.allSent : syncT.pending(n: count),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

/// Failed Sync Changes: the server refused them 5 times, so they wait for
/// the user to retry.
class _FailedRow extends StatelessWidget {
  final int count;

  /// Null disables Retry (syncing, or Sync is off).
  final VoidCallback? onRetry;

  const _FailedRow({required this.count, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final syncT = t.settings.sync;

    return ListTile(
      title: Text(
        syncT.failed(n: count),
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: context.palette.warning),
      ),
      trailing: TextButton(onPressed: onRetry, child: Text(syncT.retry)),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  final VoidCallback onRetry;

  const _LoadFailed({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final syncT = t.settings.sync;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Text(syncT.loadFailed, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          TextButton(onPressed: onRetry, child: Text(syncT.retry)),
        ],
      ),
    );
  }
}

class _SyncNowButton extends StatelessWidget {
  final bool isSyncing;

  /// Null disables the button (syncing, or Sync is off).
  final VoidCallback? onPressed;

  const _SyncNowButton({required this.isSyncing, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final syncT = t.settings.sync;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isSyncing
            ? const SizedBox.square(
                dimension: AppSpacing.iconSm,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(PiconsRegular.arrowsClockwise),
        label: Text(isSyncing ? syncT.syncing : syncT.syncNow),
      ),
    );
  }
}
