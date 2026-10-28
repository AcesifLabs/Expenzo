import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/router/settings_route.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/navigation_utils.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_empty_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_error_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';

import '../../domain/entities/watched_sender.dart';
import '../bloc/sms_watchlist_bloc.dart';
import '../bloc/sms_watchlist_event.dart';
import '../bloc/sms_watchlist_state.dart';
import 'sample_analyzer_page.dart';

class SmsWatchlistPage extends StatelessWidget {
  const SmsWatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          di.getIt<SmsWatchlistBloc>()..add(const SmsWatchlistLoadRequested()),
      child: const Scaffold(body: SmsWatchlistView()),
    );
  }
}

class SmsWatchlistView extends StatelessWidget {
  const SmsWatchlistView({super.key});

  Future<void> _openFormats(BuildContext context, WatchedSender sender) async {
    final bloc = context.read<SmsWatchlistBloc>();
    await Navigator.of(context).push(
      SlidePageRoute<void>(
        builder: (_) => SampleAnalyzerPage(source: sender.source),
      ),
    );
    bloc.add(const SmsWatchlistLoadRequested());
  }

  void _showToggleError(BuildContext context, SmsWatchlistState state) {
    final error = (state as SmsWatchlistReady).toggleError;
    if (error == null) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    final strings = t.messageTemplates.watchlist;

    return AppScaffold(
      title: strings.title,
      subtitle: strings.subtitle,
      leading: const AppBackButton(),
      child: BlocConsumer<SmsWatchlistBloc, SmsWatchlistState>(
        listenWhen: (_, state) =>
            state is SmsWatchlistReady && state.toggleError != null,
        listener: _showToggleError,
        builder: (context, state) => switch (state) {
          SmsWatchlistLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          SmsWatchlistError() => AppErrorState(
            message: strings.loadFailed,
            onRetry: () => context.read<SmsWatchlistBloc>().add(
              const SmsWatchlistLoadRequested(),
            ),
          ),
          SmsWatchlistReady(:final senders) when senders.isEmpty =>
            AppEmptyState(
              icon: PiconsRegular.chatText,
              message: strings.empty,
              actionLabel: strings.addSender,
              onAction: () => context.push(SettingsRoute.autoImport.location),
            ),
          SmsWatchlistReady(:final senders) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageGutter,
              AppSpacing.sm,
              AppSpacing.pageGutter,
              AppSpacing.xl,
            ),
            itemCount: senders.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) => _SenderTile(
              sender: senders[index],
              onTap: () => _openFormats(context, senders[index]),
            ),
          ),
        },
      ),
    );
  }
}

class _SenderTile extends StatelessWidget {
  final WatchedSender sender;
  final VoidCallback onTap;

  const _SenderTile({required this.sender, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final strings = t.messageTemplates.watchlist;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final source = sender.source;
    final details = [
      source.contactId,
      strings.formats(n: sender.formatCount),
      if (!sender.isActive) strings.paused,
    ].join(' · ');

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.smd,
        AppSpacing.sm,
        AppSpacing.smd,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source.contactName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: sender.isActive
                        ? palette.textPrimary
                        : palette.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  details,
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            label: strings.toggle(name: source.contactName),
            child: Switch(
              value: sender.isActive,
              onChanged: (value) => context.read<SmsWatchlistBloc>().add(
                SmsWatchlistSenderToggled(sender: sender, isActive: value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
