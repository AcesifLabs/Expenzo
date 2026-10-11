import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

/// The rounded square at the start of a Settings option row. [child] (an
/// icon or a short text such as a currency symbol) takes its colour from
/// the tile, so pass it without one.
class SettingsIconTile extends StatelessWidget {
  final Widget child;
  final bool selected;
  final bool enabled;

  /// Colour of [child] when enabled and not selected; defaults to
  /// `palette.textSecondary`.
  final Color? idleForeground;

  const SettingsIconTile({
    super.key,
    required this.child,
    this.selected = false,
    this.enabled = true,
    this.idleForeground,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isActive = selected && enabled;
    final fill = isActive ? palette.brandFill : palette.surfaceHigh;
    final Color foreground;
    if (!enabled) {
      foreground = palette.textTertiary;
    } else if (selected) {
      foreground = palette.onBrandFill;
    } else {
      foreground = idleForeground ?? palette.textSecondary;
    }

    return Container(
      width: AppSpacing.iconTile,
      height: AppSpacing.iconTile,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: foreground),
        child: DefaultTextStyle.merge(
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: foreground),
          child: child,
        ),
      ),
    );
  }
}
