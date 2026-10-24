import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_progress_indicator.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/group_summary.dart';

/// The frame's "Combined Balance" card, as "Spent of planned": only
/// transactions in Shared Budgets count, and there is no income figure
/// (CONTEXT.md Net, Shared Budget).
class SpentOfPlannedCard extends StatelessWidget {
  final GroupSummary summary;

  const SpentOfPlannedCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final dashboardT = t.family.dashboard;
    String money(double amount) =>
        CurrencyFormatter.formatIn(amount, summary.currencyCode);
    final spent = money(summary.spent);
    final planned = money(summary.planned);
    final monthlyBudget = summary.monthlyBudget;
    final body = textTheme.bodyMedium;
    final secondary = body?.copyWith(color: palette.textSecondary);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dashboardT.spentOfPlanned, style: textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            dashboardT.spentOfPlannedValue(spent: spent, planned: planned),
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.smd),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: BudgetProgressIndicator(
              percentage: summary.planned > 0
                  ? summary.spent / summary.planned * 100
                  : 0,
            ),
          ),
          const SizedBox(height: AppSpacing.smd),
          Text(
            dashboardT.expense(amount: spent),
            style: body?.copyWith(color: palette.expense),
          ),
          Text(dashboardT.sharedBudgetTotal(amount: planned), style: secondary),
          if (monthlyBudget != null)
            Text(
              dashboardT.ofMonthlyBudget(
                spent: money(summary.monthSpent),
                budget: money(monthlyBudget),
              ),
              style: secondary,
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            dashboardT.onlySharedNote,
            style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}
