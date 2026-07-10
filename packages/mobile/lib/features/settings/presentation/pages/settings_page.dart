import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:picons/picons.dart';

import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';

import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/currency_selector.dart';
import 'debug_db_inspector_page.dart';
import 'delete_account_dialog.dart';

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
            onSymbolSelected: (symbol) => _onCurrencySelected(context, symbol),
          ),
        ),
      );
    }
  }

  void _onCurrencySelected(BuildContext context, String symbol) {
    context.read<SettingsBloc>().add(UpdateCurrencySymbol(symbol));
    Navigator.of(context).pop();
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
        onConfirm: () => _onDeleteAccountConfirmed(context),
      ),
    );
  }

  void _onDeleteAccountConfirmed(BuildContext context) {
    context.read<SettingsBloc>().add(const DeleteAccountEvent());
  }

  void _openDbInspector(BuildContext context) {
    assert(kDebugMode, 'Database Inspector must only be opened in debug mode');
    if (!kDebugMode) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => DebugDbInspectorPage(database: di.getIt<AppDatabase>()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings',
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          final currencySymbol = settingsState is SettingsLoaded
              ? settingsState.settings.currencySymbol
              : '\$';
          final theme = settingsState is SettingsLoaded
              ? settingsState.settings.theme
              : 'system';
          final themeLabel = theme[0].toUpperCase() + theme.substring(1);

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              _SettingTile(
                icon: PiconsLight.currencyDollar,
                title: 'Currency',
                subtitle: currencySymbol,
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
                subtitle: themeLabel,
                onTap: () => _handleAppearanceTap(context),
              ),
              if (context.read<AuthBloc>().state is Authenticated)
                _SettingTile(
                  icon: PiconsLight.trash,
                  title: 'Delete Account',
                  titleColor: AppColors.error,
                  onTap: () => _handleDeleteAccountTap(context),
                ),
              if (kDebugMode)
                _SettingTile(
                  icon: Icons.storage,
                  title: 'Database Inspector',
                  subtitle: 'Debug builds only',
                  onTap: () => _openDbInspector(context),
                ),
            ],
          );
        },
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
