import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../domain/entities/goal.dart';

/// A goal's name, saved amount, progress bar, deadline and plan. Shared by
/// the dashboard goal card and the Goals page.
class GoalProgressBody extends StatelessWidget {
  final Goal goal;

  const GoalProgressBody({super.key, required this.goal});

  String? _status() {
    final cardT = t.goals.card;
    if (goal.isReached) return cardT.reached;
    final months = goal.monthsLeft(DateTime.now());
    if (months == null) return null;

    return months > 0 ? cardT.monthsLeft(n: months) : cardT.dueThisMonth;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final cardT = t.goals.card;
    final status = _status();
    final monthly = goal.monthlyContribution;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(goal.name, style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          cardT.progress(
            saved: CurrencyFormatter.format(goal.savedAmount),
            target: CurrencyFormatter.format(goal.targetAmount),
          ),
          style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: LinearProgressIndicator(
            value: goal.progress,
            color: palette.brand,
            backgroundColor: palette.progressTrack,
          ),
        ),
        if (status != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            status,
            style: goal.isReached
                ? textTheme.bodySmall?.copyWith(color: palette.brand)
                : textTheme.bodySmall,
          ),
        ],
        if (monthly != null && !goal.isReached)
          Text(
            cardT.plan(amount: CurrencyFormatter.format(monthly)),
            style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
          ),
      ],
    );
  }
}
