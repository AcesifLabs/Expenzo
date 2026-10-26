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
import 'package:expense_tracker/shared/presentation/widgets/app_badge.dart';
import 'package:expense_tracker/features/budgets/presentation/helpers/budget_display_name.dart';
import 'package:expense_tracker/features/budgets/presentation/helpers/budget_money_format.dart';

class BudgetProgressCard extends StatelessWidget {
  final BudgetProgress progress;
  final VoidCallback onTap;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetProgressCard({
    super.key,
    required this.progress,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  void _handleEdit(BuildContext context) {
    Navigator.pop(context);
    onEdit?.call();
  }

  void _handleDelete(BuildContext context) {
    Navigator.pop(context);
    onDelete?.call();
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
              if (onEdit != null)
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
              if (onDelete != null)
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
    final whole = budgetMoneyFormat(
      progress.groupId,
      fallback: CurrencyFormatter.getFormatter(decimalDigits: 0),
      decimalDigits: 0,
    );
    final card = t.budgets.card;
    final secondaryStyle = textTheme.bodySmall?.copyWith(
      color: palette.textSecondary,
    );
    final headline = summary.isOver
        ? card.overBy(amount: whole.format(-summary.remaining))
        : card.left(amount: whole.format(summary.remaining));
    final name = budgetDisplayName(progress.name);

    return Semantics(
      button: true,
      label: card.a11y(
        name: name,
        headline: headline,
        daysLeft: summary.daysLeftLabel,
      ),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onEdit == null && onDelete == null
            ? null
            : () => _showOptions(context),
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
                _CardHeader(
                  name: name,
                  isShared: progress.groupId != null,
                  daysLeft: summary.daysLeftLabel,
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

class _CardHeader extends StatelessWidget {
  final String name;
  final bool isShared;
  final String daysLeft;

  const _CardHeader({
    required this.name,
    required this.isShared,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: textTheme.titleSmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isShared) ...[
          const SizedBox(width: AppSpacing.sm),
          AppBadge(
            label: t.budgets.sharedBadge,
            color: palette.accent,
            size: AppBadgeSize.small,
          ),
        ],
        const SizedBox(width: AppSpacing.sm),

        Flexible(
          child: Text(
            daysLeft,
            style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
