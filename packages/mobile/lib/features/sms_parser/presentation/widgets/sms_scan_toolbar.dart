import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

import '../bloc/sms_scanner_view_mode.dart';

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

    return InkWell(
      key: const Key('sender_mode_chip'),
      onTap: onToggleViewMode,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isGrouped ? colors.primary.withAlpha(30) : colors.surface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PiconsRegular.buildings, size: 14, color: chipFg),
            const SizedBox(width: 4),
            Text(
              isGrouped ? 'Sender' : 'Flat List',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isGrouped ? FontWeight.w600 : FontWeight.w500,
                color: chipFg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeChip(ColorScheme colors) {
    final chipFg = colors.onSurface.withAlpha(170);

    return InkWell(
      key: const Key('date_range_chip'),
      onTap: onToggleViewMode,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PiconsRegular.calendarBlank, size: 14, color: chipFg),
            const SizedBox(width: 4),
            Text(
              rangeLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: chipFg,
              ),
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
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PiconsRegular.x, size: 14, color: chipFg),
            const SizedBox(width: 4),
            Text(
              'Clear',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: chipFg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isGrouped = viewMode == SmsScannerViewMode.groupedBySender;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
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
