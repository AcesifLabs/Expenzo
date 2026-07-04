import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import 'delete_account_dialog.dart';
import '../widgets/currency_selector.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.getIt<SettingsBloc>(),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _handleCurrencyTap(BuildContext context) {
    final state = context.read<SettingsBloc>().state;
    if (state is SettingsLoaded) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Select Currency'),
          content: CurrencySelector(
            currentSymbol: state.settings.currencySymbol,
            onSymbolSelected: (symbol) {
              context.read<SettingsBloc>().add(UpdateCurrencySymbol(symbol));
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    }
  }

  void _handleNotificationsTap(BuildContext context) {
    final state = context.read<SettingsBloc>().state;
    if (state is SettingsLoaded) {
      context.read<SettingsBloc>().add(
        UpdateNotificationsEnabled(!state.settings.notificationsEnabled),
      );
    }
  }

  void _handleAppearanceTap(BuildContext context) {
    final state = context.read<SettingsBloc>().state;
    if (state is SettingsLoaded) {
      final newTheme = state.settings.theme == 'dark' ? 'light' : 'dark';
      context.read<SettingsBloc>().add(UpdateTheme(newTheme));
    }
  }

  void _handleDeleteAccountTap(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => DeleteAccountDialog(
        onConfirm: () {
          context.read<SettingsBloc>().add(const DeleteAccountEvent());
        },
      ),
    );
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
            onTap: () => _handleCurrencyTap(context),
          ),
          _SettingTile(
            icon: PiconsLight.bell,
            title: 'Notifications',
            onTap: () => _handleNotificationsTap(context),
          ),
          _SettingTile(
            icon: PiconsLight.sun,
            title: 'Appearance',
            subtitle: 'System',
            onTap: () => _handleAppearanceTap(context),
          ),
          if (context.read<AuthBloc>().state is Authenticated)
            _SettingTile(
              icon: PiconsLight.trash,
              title: 'Delete Account',
              titleColor: AppColors.error,
              onTap: () => _handleDeleteAccountTap(context),
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
