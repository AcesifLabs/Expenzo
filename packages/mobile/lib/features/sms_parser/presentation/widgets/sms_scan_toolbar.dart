import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

import '../bloc/sms_scanner_view_mode.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class SmsScanToolbar extends StatelessWidget {
  final SmsScannerViewMode viewMode;
  final String rangeLabel;
  final VoidCallback onToggleViewMode;
  final VoidCallback onClearSelection;

  const SmsScanToolbar({
    super.key,
    required this.viewMode,
    required this.rangeLabel,
    required this.onToggleViewMode,
    required this.onClearSelection,
  });

  Widget _buildSenderChip(ColorScheme colors, bool isGrouped) {
    final chipFg = isGrouped ? colors.primary : colors.onSurface.withAlpha(170);
    final toolbarStrings = t.smsParser.toolbar;

    return InkWell(
      key: const Key('sender_mode_chip'),
      onTap: onToggleViewMode,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),

      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
        child: Center(
          widthFactor: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.smd,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isGrouped ? colors.primary.withAlpha(30) : colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PiconsRegular.buildings, size: 14, color: chipFg),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  isGrouped ? toolbarStrings.sender : toolbarStrings.flatList,
                  style: AppTypography.bodySmall.copyWith(
                    color: chipFg,
                    fontWeight: isGrouped ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRangeChip(ColorScheme colors) {
    final chipFg = colors.onSurface.withAlpha(170);

    return Container(
      key: const Key('date_range_chip'),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.smd,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PiconsRegular.calendarBlank, size: 14, color: chipFg),
            const SizedBox(width: AppSpacing.xs),
            Text(
              rangeLabel,
              style: AppTypography.bodySmall.copyWith(color: chipFg),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearChip(ColorScheme colors) {
    final chipFg = colors.onSurface.withAlpha(170);

    return InkWell(
      key: const Key('clear_selection_chip'),
      onTap: onClearSelection,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),

      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
        child: Center(
          widthFactor: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.smd,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PiconsRegular.x, size: 14, color: chipFg),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  t.smsParser.toolbar.clear,
                  style: AppTypography.bodySmall.copyWith(color: chipFg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isGrouped = viewMode == SmsScannerViewMode.groupedBySender;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smd,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          _buildSenderChip(colors, isGrouped),
          _buildRangeChip(colors),
          _buildClearChip(colors),
        ],
      ),
    );
  }
}
