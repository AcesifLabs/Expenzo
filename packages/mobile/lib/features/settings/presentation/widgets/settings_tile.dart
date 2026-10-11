import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

/// A Settings row that opens another page.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? titleColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: titleColor ?? palette.accent),
        title: Text(
          title,
          style: textTheme.bodyMedium?.copyWith(
            color: titleColor ?? palette.textPrimary,
          ),
        ),
        subtitle: switch (subtitle) {
          final s? => Text(
            s,
            style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
          ),
          _ => null,
        },
        trailing: Icon(
          PiconsRegular.caretRight,
          size: AppSpacing.iconSm,
          color: palette.textSecondary,
        ),
      ),
    );
  }
}
