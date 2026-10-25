import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

class SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SuggestionChip({super.key, required this.label, required this.onTap});

  Widget _chip(AppPalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: palette.inputFill,
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        border: Border.all(color: palette.accent.withAlpha(0x50), width: 1),
      ),
      child: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(color: palette.accent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    // The chip looks compact, but its touch area is the full 48dp.
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
          child: Center(widthFactor: 1, child: _chip(palette)),
        ),
      ),
    );
  }
}
