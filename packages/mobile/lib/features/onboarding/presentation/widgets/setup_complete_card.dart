import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';

import '../../domain/entities/onboarding_draft.dart';
import '../../domain/onboarding_plan.dart';

/// "Setup complete!" (frame `OnboardingSavingsTimeline`): what Finish setup
/// will save, with icons instead of the design's emoji.
class SetupCompleteCard extends StatelessWidget {
  final OnboardingDraft draft;

  const SetupCompleteCard({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final completeT = t.onboarding.complete;
    final budgets =
        draft.createBudgets &&
        !budgetSplitFor(
          monthlyIncome: draft.monthlyIncome,
          recurringTotal: recurringMonthlyTotal(draft.recurring),
        ).isEmpty;
    final recurring = draft.recurring.length;
    final goal = draft.goal;

    Widget row(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: AppSpacing.iconSm, color: palette.accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: textTheme.bodyMedium)),
        ],
      ),
    );

    return AppCard(
      backgroundColor: palette.surfaceHigh,
      borderRadius: AppSpacing.radiusCard,
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            completeT.title,
            style: textTheme.titleLarge?.copyWith(color: palette.brand),
          ),
          if (budgets) row(PiconsRegular.wallet, completeT.budgets),
          if (recurring > 0)
            row(PiconsRegular.repeat, completeT.recurring(n: recurring)),
          if (goal != null)
            row(PiconsRegular.target, completeT.goal(name: goal.name)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            completeT.tip,
            style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}
