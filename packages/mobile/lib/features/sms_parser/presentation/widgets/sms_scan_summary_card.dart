import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class SmsScanSummaryCard extends StatelessWidget {
  final String rangeLabel;
  final int matchCount;
  final int selectedCount;

  const SmsScanSummaryCard({
    super.key,
    required this.rangeLabel,
    required this.matchCount,
    required this.selectedCount,
  });

  Widget _buildStat(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: onSurface.withAlpha(170),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(
              color: valueColor ?? onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.smd),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      ),
      child: Row(
        children: [
          _buildStat(context, t.smsParser.summary.range, rangeLabel),
          const SizedBox(width: AppSpacing.sm),
          _buildStat(context, t.smsParser.summary.matches, '$matchCount'),
          const SizedBox(width: AppSpacing.sm),
          _buildStat(
            context,
            t.smsParser.summary.selected,
            '$selectedCount',
            valueColor: colors.primary,
          ),
        ],
      ),
    );
  }
}
