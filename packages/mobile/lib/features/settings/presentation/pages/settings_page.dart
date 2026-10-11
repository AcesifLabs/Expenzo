import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/services/feedback_mailer.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

import '../../domain/entities/user_settings.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/currency_selector.dart';
import 'debug_db_inspector_page.dart';
import 'delete_account_dialog.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SettingsBloc is an app-wide singleton (ExpenzoApp listens to it for the
    // theme), so provide it by value: `create` would close it when this page
    // is popped and break every later settings change.
    // Pushed above the app shell, so it needs its own themed Scaffold.
    return BlocProvider.value(
      value: di.getIt<SettingsBloc>(),
      child: const Scaffold(body: SettingsView()),
    );
  }
}

Future<bool> _requestNotificationPermission() async =>
    (await Permission.notification.request()).isGranted;

class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    this.requestNotificationPermission = _requestNotificationPermission,
  });

  static List<(String, String)> get _themeOptions {
    final themeT = t.enums.theme;

    return [
      ('system', themeT.system),
      ('light', themeT.light),
      ('dark', themeT.dark),
    ];
  }

  // Language names are shown in their own script, never translated.
  static List<(String, String)> get _languageOptions => [
    ('system', t.enums.theme.system),
    ('en', 'English'),
    ('bn', 'বাংলা'),
  ];

  static String _languageLabel(String languageCode) {
    for (final (value, label) in _languageOptions) {
      if (value == languageCode) return label;
    }

    return t.enums.theme.system;
  }

  static String _themeLabel(String theme) {
    for (final (value, label) in _themeOptions) {
      if (value == theme) return label;
    }

    return t.enums.theme.system;
  }

  /// Asks Android for permission to post notifications; replaceable in tests.
  final Future<bool> Function() requestNotificationPermission;

  void _handleCurrencyTap(BuildContext context) {
    final state = context.read<SettingsBloc>().state;
    if (state is SettingsLoaded) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(t.settings.currency),
          content: CurrencySelector(
            currentCode: state.settings.currencyCode,
            onCurrencySelected: (code) => _onCurrencySelected(context, code),
          ),
        ),
      );
    }
  }

  void _onCurrencySelected(BuildContext context, String code) {
    context.read<SettingsBloc>().add(UpdateCurrency(code));
    Navigator.of(context).pop();
  }

  Future<void> _onNotificationsChanged(
    BuildContext context,
    bool enabled,
  ) async {
    final bloc = context.read<SettingsBloc>();
    // Turning alerts on is pointless if Android won't show them.
    if (enabled && !await requestNotificationPermission()) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(t.settings.notificationsBlocked)),
        );

      return;
    }
    bloc.add(UpdateNotificationsEnabled(enabled));
  }

  Future<void> _handleAppearanceTap(
    BuildContext context,
    String current,
  ) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(t.settings.appearance),
        children: [
          for (final (value, label) in _themeOptions)
            ListTile(
              title: Text(label),
              selected: value == current,
              trailing: value == current
                  ? const Icon(PiconsRegular.check)
                  : null,
              onTap: () => Navigator.of(dialogContext).pop(value),
            ),
        ],
      ),
    );
    if (picked != null && context.mounted) {
      context.read<SettingsBloc>().add(UpdateTheme(picked));
    }
  }

  Future<void> _handleLanguageTap(BuildContext context, String current) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(t.settings.language.title),
        children: [
          for (final (value, label) in _languageOptions)
            ListTile(
              title: Text(label),
              selected: value == current,
              trailing: value == current
                  ? const Icon(PiconsRegular.check)
                  : null,
              onTap: () => Navigator.of(dialogContext).pop(value),
            ),
        ],
      ),
    );
    if (picked != null && context.mounted) {
      context.read<SettingsBloc>().add(UpdateLanguage(picked));
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

  List<Widget> _preferencesSection(
    BuildContext context,
    UserSettings? settings,
  ) {
    final settingsT = t.settings;
    final budgetAlertsT = settingsT.budgetAlerts;
    final currency = CurrencyConfig.byCode(
      settings?.currencyCode ?? CurrencyConfig.defaultCode,
    );
    final theme = settings?.theme ?? 'system';
    final languageCode = settings?.languageCode ?? 'system';

    return [
      _SectionHeader(settingsT.sections.preferences),
      _SettingTile(
        icon: PiconsRegular.currencyCircleDollar,
        title: settingsT.currency,
        subtitle: '${currency.displayName} (${currency.symbol.trim()})',
        onTap: () => _handleCurrencyTap(context),
      ),
      _SettingTile(
        icon: PiconsRegular.sun,
        title: settingsT.appearance,
        subtitle: _themeLabel(theme),
        onTap: () => _handleAppearanceTap(context, theme),
      ),
      _SettingTile(
        icon: PiconsRegular.translate,
        title: settingsT.language.title,
        subtitle: _languageLabel(languageCode),
        onTap: () => _handleLanguageTap(context, languageCode),
      ),
      SwitchListTile(
        secondary: const Icon(PiconsRegular.bell),
        title: Text(budgetAlertsT.title),
        subtitle: Text(budgetAlertsT.subtitle),
        value: settings?.notificationsEnabled ?? false,
        onChanged: settings == null
            ? null
            : (enabled) => _onNotificationsChanged(context, enabled),
      ),
    ];
  }

  List<Widget> _automationSection(BuildContext context) {
    final settingsT = t.settings;
    final commonT = t.common;
    final recurringT = settingsT.recurring;

    return [
      _SectionHeader(settingsT.sections.automation),
      _SettingTile(
        icon: PiconsRegular.chatText,
        title: commonT.autoImport,
        subtitle: settingsT.autoImportSubtitle,
        onTap: () => context.push('/settings/auto-import'),
      ),
      _SettingTile(
        icon: PiconsRegular.funnel,
        title: commonT.matchingRules,
        subtitle: settingsT.matchingRulesSubtitle,
        onTap: () => context.push('/settings/matching-rules'),
      ),
      _SettingTile(
        icon: PiconsRegular.repeat,
        title: recurringT.title,
        subtitle: recurringT.subtitle,
        onTap: () => context.push('/settings/recurring'),
      ),
    ];
  }

  List<Widget> _supportSection(BuildContext context) {
    final settingsT = t.settings;

    return [
      _SectionHeader(settingsT.sections.support),
      _SettingTile(
        icon: PiconsRegular.envelopeSimple,
        title: t.common.sendFeedback,
        subtitle: settingsT.feedbackSubtitle,
        onTap: () => sendFeedback(context),
      ),
    ];
  }

  List<Widget> _accountSection(BuildContext context) {
    final settingsT = t.settings;
    final signInT = settingsT.signIn;
    final isSignedIn = context.watch<AuthBloc>().state is Authenticated;

    return [
      _SectionHeader(settingsT.sections.account),
      if (isSignedIn) ...[
        _SettingTile(
          icon: PiconsRegular.signOut,
          title: settingsT.signOut,
          onTap: () => context.read<AuthBloc>().add(const SignOutRequested()),
        ),
        _SettingTile(
          icon: PiconsRegular.trash,
          title: settingsT.deleteAccount,
          titleColor: Theme.of(context).colorScheme.error,
          onTap: () => _handleDeleteAccountTap(context),
        ),
      ] else
        _SettingTile(
          icon: PiconsRegular.signIn,
          title: signInT.title,
          subtitle: signInT.subtitle,
          onTap: () => context.push('/login'),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: t.settings.title,
      leading: const AppBackButton(),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          final settings = settingsState is SettingsLoaded
              ? settingsState.settings
              : null;

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            children: [
              ..._preferencesSection(context, settings),
              ..._automationSection(context),
              ..._supportSection(context),
              ..._accountSection(context),
              if (kDebugMode) ...[
                const _SectionHeader('Developer'),
                _SettingTile(
                  icon: PiconsRegular.database,
                  title: 'Database inspector',
                  onTap: () => _openDbInspector(context),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
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
