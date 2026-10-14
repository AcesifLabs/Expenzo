import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';

import 'settings_icon_tile.dart';

/// A Settings row with an icon tile and a switch.
class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;

  /// Null disables the switch; it still shows [value].
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

    return ListTile(
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
    );
  }
}
