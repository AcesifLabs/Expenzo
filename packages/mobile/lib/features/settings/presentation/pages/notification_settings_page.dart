import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/week_utils.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/services/notification_permission.dart'
    as notification_permission;

import '../../domain/entities/notification_toggle.dart';
import '../../domain/entities/user_settings.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../widgets/settings_icon_tile.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_state_view.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SettingsBloc is an app-wide singleton; `create` would close it on pop.
    return BlocProvider.value(
      value: di.getIt<SettingsBloc>(),
      child: const Scaffold(body: NotificationSettingsView()),
    );
  }
}

Future<void> _openAppSettings() async {
  await permissions.openAppSettings();
}

/// The master switch plus one toggle per notification kind (frame
/// `NotificationSettingsScreen`, without Push and Email: ADR 0011).
class NotificationSettingsView extends StatefulWidget {
  /// Replaceable in tests, like the permission calls below.
  final Future<bool> Function() requestNotificationPermission;
  final Future<bool> Function() notificationPermissionGranted;
  final Future<void> Function() openSystemSettings;

  const NotificationSettingsView({
    super.key,
    this.requestNotificationPermission =
        notification_permission.requestNotificationPermission,
    this.notificationPermissionGranted =
        notification_permission.notificationPermissionGranted,
    this.openSystemSettings = _openAppSettings,
  });

  @override
  State<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  /// The day the weekly summary goes out (the day before the first day of
  /// week), in the app language.
  static String _summaryDayName(UserSettings settings) {
    final locale = LocaleSettings.currentLocale;
    final firstDay = settings.effectiveFirstDayOfWeek(locale.languageCode);
    // Jan 1, 2024 is a Monday, so day n of that month has weekday n.
    final sample = DateTime(
      2024,
      1,
      summaryWeekday(firstWeekday: firstDay.weekday),
    );

    return DateFormat.EEEE(locale.languageTag).format(sample);
  }

  AppLifecycleListener? _lifecycle;

  /// Null until the first check, so the blocked row doesn't flash.
  bool? _permissionGranted;

  /// A permission prompt is open; ignore further taps on the master.
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    _onResume();
  }

  Future<void> _refreshPermission() async {
    final granted = await widget.notificationPermissionGranted();
    if (!mounted || granted == _permissionGranted) return;
    setState(() => _permissionGranted = granted);
  }

  void _onResume() => unawaited(_refreshPermission());

  void _onMasterTapped(bool enabled) => unawaited(_onMasterChanged(enabled));

  Future<void> _onMasterChanged(bool enabled) async {
    if (_requesting) return;
    final bloc = context.read<SettingsBloc>();
    if (enabled) {
      _requesting = true;
      final granted = await widget.requestNotificationPermission();
      _requesting = false;
      if (!mounted) return;
      setState(() => _permissionGranted = granted);
      // Turning notifications on is pointless if Android won't show them.
      if (!granted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(content: Text(t.settings.notificationsBlocked)),
          );

        return;
      }
    }
    bloc.add(UpdateNotificationsEnabled(enabled));
  }

  void _onToggleChanged(NotificationToggle toggle, bool enabled) {
    context.read<SettingsBloc>().add(UpdateNotificationToggle(toggle, enabled));
  }

  void _openSettings() {
    widget.openSystemSettings();
  }

  /// Null while the master switch is off, which disables the row.
  ValueChanged<bool>? _toggleHandler(
    UserSettings settings,
    NotificationToggle toggle,
  ) {
    if (!settings.notificationsEnabled) return null;

    return (enabled) => _onToggleChanged(toggle, enabled);
  }

  Widget _generalSection(UserSettings settings) {
    final notificationsT = t.settings.notifications;
    final masterT = notificationsT.master;
    final showBlocked =
        settings.notificationsEnabled && _permissionGranted == false;

    return SettingsSection(
      title: notificationsT.sections.general,
      children: [
        if (showBlocked) _BlockedRow(onOpenSettings: _openSettings),
        _ToggleRow(
          icon: PiconsRegular.bell,
          title: masterT.title,
          subtitle: masterT.subtitle,
          value: settings.notificationsEnabled,
          onChanged: _onMasterTapped,
        ),
      ],
    );
  }

  Widget _budgetSection(UserSettings settings) {
    final notificationsT = t.settings.notifications;
    final overT = notificationsT.over;
    final nearLimitT = notificationsT.nearLimit;
    final weeklyT = notificationsT.weekly;

    return SettingsSection(
      title: notificationsT.sections.budgetAlerts,
      children: [
        _ToggleRow(
          icon: PiconsRegular.warningCircle,
          title: overT.title,
          subtitle: overT.subtitle,
          value: settings.budgetOverAlertsEnabled,
          onChanged: _toggleHandler(settings, NotificationToggle.budgetOver),
        ),
        _ToggleRow(
          icon: PiconsRegular.bell,
          title: nearLimitT.title,
          subtitle: nearLimitT.subtitle,
          value: settings.budgetNearLimitAlertsEnabled,
          onChanged: _toggleHandler(
            settings,
            NotificationToggle.budgetNearLimit,
          ),
        ),
        _ToggleRow(
          icon: PiconsRegular.chartBar,
          title: weeklyT.title,
          subtitle: weeklyT.subtitle(day: _summaryDayName(settings)),
          value: settings.weeklySummaryEnabled,
          onChanged: _toggleHandler(settings, NotificationToggle.weeklySummary),
        ),
      ],
    );
  }

  Widget _recurringSection(UserSettings settings) {
    final notificationsT = t.settings.notifications;
    final remindersT = notificationsT.reminders;

    return SettingsSection(
      title: notificationsT.sections.recurring,
      children: [
        _ToggleRow(
          icon: PiconsRegular.clock,
          title: remindersT.title,
          subtitle: remindersT.subtitle,
          value: settings.recurringRemindersEnabled,
          onChanged: _toggleHandler(
            settings,
            NotificationToggle.recurringReminders,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext _, UserSettings settings) {
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        _generalSection(settings),
        _budgetSection(settings),
        _recurringSection(settings),
      ],
    );
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: t.settings.notifications.title,
      leading: const AppBackButton(),
      child: SettingsStateView(builder: _buildBody),
    );
  }
}

/// A notification switch row with its icon tile, as in the frame.
class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;

  /// Null disables the switch; it still shows [value].
  final ValueChanged<bool>? onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: SettingsIconTile(
        idleForeground: palette.accent,
        child: Icon(icon),
      ),
      title: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(color: palette.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

/// Shown while the master switch is on but Android blocks notifications.
class _BlockedRow extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const _BlockedRow({required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final error = Theme.of(context).colorScheme.error;
    final blockedT = t.settings.notifications.blocked;

    return ListTile(
      leading: SettingsIconTile(
        idleForeground: error,
        child: const Icon(PiconsRegular.bellSlash),
      ),
      title: Text(
        blockedT.title,
        style: textTheme.bodyMedium?.copyWith(color: palette.textPrimary),
      ),
      trailing: TextButton(
        onPressed: onOpenSettings,
        child: Text(
          blockedT.action,
          style: textTheme.labelLarge?.copyWith(color: palette.brand),
        ),
      ),
    );
  }
}
