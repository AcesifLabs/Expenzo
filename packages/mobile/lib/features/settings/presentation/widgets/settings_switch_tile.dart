import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';

import 'settings_icon_tile.dart';

class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;

  final ValueChanged<bool>? onChanged;

  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final subtitle = this.subtitle;

    return MergeSemantics(
      child: ListTile(
        onTap: onChanged == null ? null : () => onChanged?.call(!value),
        leading: SettingsIconTile(
          idleForeground: palette.accent,
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: textTheme.bodyMedium?.copyWith(color: palette.textPrimary),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: palette.textSecondary,
                ),
              ),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}
