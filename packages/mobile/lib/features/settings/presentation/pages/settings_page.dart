import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings',
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _SettingTile(
            icon: PhosphorIcons.currencyDollar(PhosphorIconsStyle.light),
            title: 'Currency',
            subtitle: 'USD (\$)',
            onTap: () {},
          ),
          _SettingTile(
            icon: PhosphorIcons.bell(PhosphorIconsStyle.light),
            title: 'Notifications',
            onTap: () {},
          ),
          _SettingTile(
            icon: PhosphorIcons.sun(PhosphorIconsStyle.light),
            title: 'Appearance',
            subtitle: 'System',
            onTap: () {},
          ),
          _SettingTile(
            icon: PhosphorIcons.trash(PhosphorIconsStyle.light),
            title: 'Delete Account',
            titleColor: AppColors.error,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? titleColor;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: titleColor ?? colors.onSurface),
      title: Text(
        title,
        style: TextStyle(color: titleColor ?? colors.onSurface, fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.regular), size: 16, color: colors.onSurface.withAlpha(100)),
    );
  }
}
