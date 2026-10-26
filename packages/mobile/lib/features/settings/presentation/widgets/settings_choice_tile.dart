import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'settings_icon_tile.dart';

class SettingsChoiceTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const SettingsChoiceTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.selected,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final titleColor = enabled ? palette.textPrimary : palette.textTertiary;
    final subtitleColor = enabled
        ? palette.textSecondary
        : palette.textTertiary;
    final localIcon = icon;

    return MergeSemantics(
      child: Semantics(
        selected: selected,
        enabled: enabled,
        inMutuallyExclusiveGroup: true,
        child: ListTile(
          enabled: enabled,
          selected: selected,
          onTap: enabled ? onTap : null,
          leading: localIcon == null
              ? null
              : SettingsIconTile(
                  selected: selected,
                  enabled: enabled,
                  child: Icon(localIcon),
                ),
          title: Text(
            title,
            style: textTheme.bodyLarge?.copyWith(
              color: titleColor,
              fontWeight: selected ? FontWeight.w700 : null,
            ),
          ),
          subtitle: switch (subtitle) {
            final s? => Text(
              s,
              style: textTheme.bodySmall?.copyWith(color: subtitleColor),
            ),
            _ => null,
          },
          trailing: selected
              ? Icon(PiconsRegular.checkCircle, color: palette.brand)
              : null,
        ),
      ),
    );
  }
}
