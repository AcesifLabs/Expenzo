import 'package:flutter/material.dart';

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
          const SizedBox(height: 2),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildStat(context, 'Range', rangeLabel),
          const SizedBox(width: 8),
          _buildStat(context, 'Matches', '$matchCount'),
          const SizedBox(width: 8),
          _buildStat(
            context,
            'Selected',
            '$selectedCount',
            valueColor: colors.primary,
          ),
        ],
      ),
    );
  }
}
