import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/budgets/presentation/helpers/budget_display_name.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/group_summary.dart';

/// "Shared budget progress": each Shared Budget's server spent against its
/// effective amount this period.
class SharedBudgetProgressList extends StatelessWidget {
  final GroupSummary summary;

  const SharedBudgetProgressList({super.key, required this.summary});

  void _openBudgets(BuildContext context) =>
      context.go(AppRootTab.budgets.location);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final dashboardT = t.family.dashboard;
    String money(double amount) => CurrencyFormatter.formatIn(
      amount,
      summary.currencyCode,
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.settings.family.sections.sharedBudgets,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (summary.sharedBudgets.isEmpty)
          Text(
            dashboardT.noSharedBudgets,
            style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
        for (final budget in summary.sharedBudgets)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        budgetDisplayName(budget.name),
                        style: textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${money(budget.spent)} / ${money(budget.effectiveAmount)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  child: BudgetProgressIndicator(
                    percentage: budget.ratio * 100,
                    height: 8,
                  ),
                ),
              ],
            ),
          ),
        Center(
          child: TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, AppSpacing.minTapTarget),
            ),
            onPressed: () => _openBudgets(context),
            child: Text(dashboardT.seeAllBudgets),
          ),
        ),
      ],
    );
  }
}
