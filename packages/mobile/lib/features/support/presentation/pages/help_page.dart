import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/config/app_config.dart';
import 'package:expense_tracker/core/router/help_route.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_tile.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/services/external_pages.dart';
import 'package:expense_tracker/shared/services/feedback_mailer.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  bool _busy = false;

  void _openTutorial() => context.push('/tutorial');

  Future<void> _replaySetup() async {
    final replayT = t.support.help.replaySetup;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(replayT.confirmTitle),
        content: Text(replayT.confirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(t.onboarding.common.continueLabel),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && mounted) unawaited(context.push('/onboarding'));
  }

  void _onReplaySetup() => unawaited(_replaySetup());

  void _openFaq() => context.push(HelpRoute.faq.location);

  void _openRate() => context.push(HelpRoute.rate.location);

  void _openAbout() => context.push(HelpRoute.about.location);

  void _openPrivacy() => unawaited(
    _whileBusy(
      () => openExternalPage(context, () => AppConfig.privacyPolicyUri),
    ),
  );

  void _openTerms() => unawaited(
    _whileBusy(
      () => openExternalPage(context, () => AppConfig.termsOfServiceUri),
    ),
  );

  void _onContactSupport() =>
      unawaited(_whileBusy(() => sendFeedback(context)));

  Future<void> _whileBusy(Future<Object?> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  List<Widget> _rows() {
    final helpT = t.support.help;

    return [
      SettingsTile(
        icon: PiconsRegular.playCircle,
        title: helpT.watchTutorial,
        onTap: _openTutorial,
      ),
      SettingsTile(
        icon: PiconsRegular.arrowCounterClockwise,
        title: helpT.replaySetup.title,
        subtitle: helpT.replaySetup.rowSubtitle,
        onTap: _onReplaySetup,
      ),
      SettingsTile(
        icon: PiconsRegular.question,
        title: helpT.faq,
        onTap: _openFaq,
      ),
      IgnorePointer(
        ignoring: _busy,
        child: SettingsTile(
          icon: PiconsRegular.headset,
          title: helpT.contactSupport,
          onTap: _onContactSupport,
        ),
      ),
      SettingsTile(
        icon: PiconsRegular.star,
        title: helpT.rateApp,
        onTap: _openRate,
      ),
      IgnorePointer(
        ignoring: _busy,
        child: SettingsTile(
          icon: PiconsRegular.shieldCheck,
          title: helpT.privacyPolicy,
          onTap: _openPrivacy,
        ),
      ),
      IgnorePointer(
        ignoring: _busy,
        child: SettingsTile(
          icon: PiconsRegular.fileText,
          title: helpT.termsOfService,
          onTap: _openTerms,
        ),
      ),
      SettingsTile(
        icon: PiconsRegular.info,
        title: helpT.about,
        onTap: _openAbout,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final divider = Divider(height: 1, thickness: 1, color: palette.divider);
    final rows = _rows();

    return Scaffold(
      body: AppScaffold(
        title: t.support.help.title,
        leading: const AppBackButton(),
        child: ListView(
          padding: AppSpacing.pagePadding,
          children: [
            const SizedBox(height: AppSpacing.md),

            AppCard(
              backgroundColor: palette.surface,
              borderRadius: AppSpacing.radiusCard,
              padding: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final (index, row) in rows.indexed) ...[
                    if (index > 0) divider,
                    row,
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
