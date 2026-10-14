import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';
import 'package:expense_tracker/features/budgets/presentation/helpers/budget_progress_colors.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/features/budgets/presentation/helpers/budget_summary.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/features/budgets/presentation/helpers/budget_display_name.dart';

class BudgetProgressCard extends StatelessWidget {
  final BudgetProgress progress;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetProgressCard({
    super.key,
    required this.progress,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  void _handleEdit(BuildContext context) {
    Navigator.pop(context);
    onEdit();
  }

  void _handleDelete(BuildContext context) {
    Navigator.pop(context);
    onDelete();
  }

  void _showOptions(BuildContext context) {
    final palette = context.palette;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusCard),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  PiconsRegular.pencilSimple,
                  color: palette.textPrimary,
                ),
                title: Text(
                  t.budgets.edit,
                  style: TextStyle(color: palette.textPrimary),
                ),
                onTap: () => _handleEdit(context),
              ),
              ListTile(
                leading: Icon(PiconsRegular.trash, color: palette.error),
                title: Text(
                  t.common.delete,
                  style: TextStyle(color: palette.error),
                ),
                onTap: () => _handleDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(AppPalette palette) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: SizedBox(
        height: 12,
        child: LinearProgressIndicator(
          value: (progress.percentage / 100).clamp(0.0, 1.0),
          backgroundColor: palette.progressTrack,
          color: budgetProgressColor(palette, progress.percentage),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final summary = BudgetSummary.of(progress);
    final whole = CurrencyFormatter.getFormatter(decimalDigits: 0);
    final card = t.budgets.card;
    final secondaryStyle = textTheme.bodySmall?.copyWith(
      color: palette.textSecondary,
    );
    final headline = summary.isOver
        ? card.overBy(amount: whole.format(-summary.remaining))
        : card.left(amount: whole.format(summary.remaining));

    return Semantics(
      button: true,
      label: card.a11y(
        name: budgetDisplayName(progress.name),
        headline: headline,
        daysLeft: summary.daysLeftLabel,
      ),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showOptions(context),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          ),
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        budgetDisplayName(progress.name),
                        style: textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Wraps rather than truncates at large text sizes, so the
                    // number of days stays readable.
                    Flexible(
                      child: Text(
                        summary.daysLeftLabel,
                        style: secondaryStyle,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  headline,
                  style: textTheme.titleLarge?.copyWith(
                    color: summary.isOver ? palette.expense : null,
                    fontFeatures: AppTypography.tabularFigures,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  card.spentOf(
                    spent: whole.format(progress.spentAmount),
                    total: whole.format(progress.effectiveAmount),
                  ),
                  style: secondaryStyle,
                ),
                const SizedBox(height: AppSpacing.smd),
                _buildProgressBar(palette),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
