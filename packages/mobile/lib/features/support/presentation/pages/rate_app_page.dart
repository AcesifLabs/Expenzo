import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/services/feedback_mailer.dart';

import '../../data/services/app_review_service.dart';
import '../../domain/rate_action.dart';

/// Rate the app (design frame `RateAppScreen`): 4–5 stars ask the store for a
/// review, 1–3 stars open the feedback email. Opened only from Help, so
/// nothing is stored and there is no prompt to suppress.
class RateAppPage extends StatefulWidget {
  const RateAppPage({super.key});

  @override
  State<RateAppPage> createState() => _RateAppPageState();
}

class _RateAppPageState extends State<RateAppPage> {
  int? _stars;
  bool _busy = false;

  void _onStarTap(int stars) => setState(() => _stars = stars);

  void _close() => context.pop();

  void _onPrimaryPressed() => unawaited(_onPrimary());

  Future<void> _onPrimary() async {
    final stars = _stars;
    if (stars == null || _busy) return;
    setState(() => _busy = true);
    try {
      switch (rateActionFor(stars)) {
        case RateAction.storeReview:
          await di.featureDependenciesReady;
          await di.getIt<AppReviewService>().requestReview();
        case RateAction.feedbackEmail:
          await sendFeedback(context);
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _primaryButton() {
    final stars = _stars;
    final rateT = t.support.rate;
    final label =
        stars != null && rateActionFor(stars) == RateAction.feedbackEmail
        ? rateT.tellUs
        : rateT.writeReview;

    return SizedBox(
      width: double.infinity,
      height: AppSpacing.xxl,
      child: ElevatedButton(
        onPressed: stars == null || _busy ? null : _onPrimaryPressed,
        child: _busy
            ? const SizedBox.square(
                dimension: AppSpacing.md,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rateT = t.support.rate;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    // Pushed above the app shell, so it needs its own themed Scaffold.
    // Leaving mid-request is blocked: the request pops this page itself.
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        body: AppScaffold(
          title: rateT.title,
          leading: const AppBackButton(),
          child: ListView(
            padding: AppSpacing.pagePadding,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Icon(PiconsRegular.star, size: 48, color: palette.warning),
              const SizedBox(height: AppSpacing.md),
              Text(
                rateT.heading,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                rateT.subtitle,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _StarRow(stars: _stars, onTap: _onStarTap),
              const SizedBox(height: AppSpacing.lg),
              _primaryButton(),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _busy ? null : _close,
                  child: Text(rateT.maybeLater, style: textTheme.labelLarge),
                ),
              ),
              TextButton(
                onPressed: _busy ? null : _close,
                child: Text(
                  rateT.noThanks,
                  style: textTheme.labelLarge?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

/// Five tappable stars; the first [stars] are filled (a selected state, the
/// one place besides the selected tab where DESIGN.md allows Fill).
class _StarRow extends StatelessWidget {
  final int? stars;
  final ValueChanged<int> onTap;

  const _StarRow({required this.stars, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = context.palette.warning;
    final chosen = stars ?? 0;

    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < 5; i++)
          IconButton(
            tooltip: t.support.rate.starLabel(n: i + 1),
            constraints: const BoxConstraints(
              minWidth: AppSpacing.minTapTarget,
              minHeight: AppSpacing.minTapTarget,
            ),
            iconSize: 40,
            color: color,
            icon: Icon(i < chosen ? PiconsFill.star : PiconsRegular.star),
            onPressed: () => onTap(i + 1),
          ),
      ],
    );
  }
}
