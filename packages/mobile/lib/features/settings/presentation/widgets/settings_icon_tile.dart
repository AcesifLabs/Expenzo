import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

class SettingsIconTile extends StatelessWidget {
  final Widget child;
  final bool selected;
  final bool enabled;

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
