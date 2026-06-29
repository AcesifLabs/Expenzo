import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _handleCurrencyTap() {
    // TODO: navigate to currency settings
  }

  void _handleNotificationsTap() {
    // TODO: navigate to notification settings
  }

  void _handleAppearanceTap() {
    // TODO: navigate to appearance settings
  }

  void _handleDeleteAccountTap() {
    // TODO: show delete account dialog
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings',
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _SettingTile(
            icon: PiconsLight.currencyDollar,
            title: 'Currency',
            subtitle: 'USD (\$)',
            onTap: _handleCurrencyTap,
          ),
          _SettingTile(
            icon: PiconsLight.bell,
            title: 'Notifications',
            onTap: _handleNotificationsTap,
          ),
          _SettingTile(
            icon: PiconsLight.sun,
            title: 'Appearance',
            subtitle: 'System',
            onTap: _handleAppearanceTap,
          ),
          _SettingTile(
            icon: PiconsLight.trash,
            title: 'Delete Account',
            titleColor: AppColors.error,
            onTap: _handleDeleteAccountTap,
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
        style: TextStyle(
          color: titleColor ?? colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: switch (subtitle) {
        final s? => Text(s),
        _ => null,
      },
      trailing: Icon(
        PiconsRegular.caretRight,
        size: 16,
        color: colors.onSurface.withAlpha(100),
      ),
    );
  }
}
