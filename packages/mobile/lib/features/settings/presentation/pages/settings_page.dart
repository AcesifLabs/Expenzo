import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:picons/picons.dart';

import 'package:expense_tracker/core/constants/app_font_size.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/core/router/settings_route.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/services/feedback_mailer.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

import '../../domain/entities/notification_toggle.dart';
import '../../domain/entities/user_settings.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_state_view.dart';
import '../widgets/settings_tile.dart';
import 'debug_db_inspector_page.dart';
import 'appearance_page.dart';
import 'delete_account_dialog.dart';
import 'home_page_settings_page.dart';
import 'language_page.dart';
import 'number_format_page.dart';
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

/// The main Settings list. Sections and rows, top to bottom (SAAP-60 README,
/// "Settings row order"):
///
/// | Section (builder) | Rows now | Rows later tickets add, in final order |
/// |---|---|---|
/// | Profile & account (`_accountSection`) | Sign in (signed out) / Delete account (signed in) | SAAP-72 profile card above the section, then My profile (Delete account moves into it); SAAP-75 Family group right after My profile |
/// | Preferences (`_preferencesSection`) | Default currency, Number format, Font size, Appearance, Calendar | none |
/// | Notifications (`_notificationsSection`) | Notifications | none |
/// | Data & budget (`_dataSection`) | Recurring transactions | Recurring transactions, Sync (SAAP-71), Export data (SAAP-69), Delete all data (SAAP-70) |
/// | Automation (`_automationSection`) | Auto-import from SMS, Matching rules | none |
/// | General (`_generalSection`) | Language, Home page, Category settings | none |
/// | Support (`_supportSection`) | Send feedback | SAAP-73 adds Help & Support and removes Send feedback |
/// | none (`_signOutRow`) | Sign out (signed in only), always last | none |
/// | Developer (`kDebugMode` only) | Database inspector | none |
///
/// Rows follow this order inside a section. A new row goes into an existing
/// section. Hide a row (signed out, debug) with collection-if; a section with
/// no visible rows disappears. No "coming soon" rows (ADR 0011). The Sync row
/// reads "Sync" / "Keep your data on all your devices"; the UI never says
/// "backup".
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  /// "Off", or how many of the four kinds are on.
  static String _notificationsSummary(UserSettings? settings) {
    final notificationsT = t.settings.notifications;
    if (settings == null || !settings.notificationsEnabled) {
      return notificationsT.rowSubtitleOff;
    }
    final on = NotificationToggle.values.where(settings.isEnabled).length;

    return notificationsT.rowSubtitle(n: on);
  }

  void _openCurrency(BuildContext context) {
    context.push(SettingsRoute.currency.location);
  }

  void _openNumberFormat(BuildContext context) {
    context.push(SettingsRoute.numberFormat.location);
  }

  void _openFontSize(BuildContext context) {
    context.push(SettingsRoute.fontSize.location);
  }

  void _openCalendar(BuildContext context) {
    context.push(SettingsRoute.calendar.location);
  }

  void _openNotifications(BuildContext context) {
    context.push(SettingsRoute.notifications.location);
  }

  void _openAppearance(BuildContext context) {
    context.push(SettingsRoute.appearance.location);
  }

  void _openLanguage(BuildContext context) {
    context.push(SettingsRoute.language.location);
  }

  void _openHomePage(BuildContext context) {
    context.push(SettingsRoute.homePage.location);
  }

  void _openCategories(BuildContext context) {
    context.push(SettingsRoute.categories.location);
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

  Widget _accountSection(BuildContext context) {
    final settingsT = t.settings;
    final signInT = settingsT.signIn;
    final isSignedIn = context.watch<AuthBloc>().state is Authenticated;

    return SettingsSection(
      title: settingsT.sections.account,
      children: [
        if (isSignedIn)
          SettingsTile(
            icon: PiconsRegular.trash,
            title: settingsT.deleteAccount,
            titleColor: Theme.of(context).colorScheme.error,
            onTap: () => _handleDeleteAccountTap(context),
          )
        else
          SettingsTile(
            icon: PiconsRegular.signIn,
            title: signInT.title,
            subtitle: signInT.subtitle,
            onTap: () => context.push('/login'),
          ),
      ],
    );
  }

  Widget _preferencesSection(BuildContext context, UserSettings? settings) {
    final settingsT = t.settings;
    final currency = CurrencyConfig.byCode(
      settings?.currencyCode ?? CurrencyConfig.defaultCode,
    );
    final theme = settings?.theme ?? 'system';
    final languageCode = LocaleSettings.currentLocale.languageCode;
    final firstDay =
        settings?.effectiveFirstDayOfWeek(languageCode) ??
        FirstDayOfWeek.defaultFor(languageCode);

    return SettingsSection(
      title: settingsT.sections.preferences,
      children: [
        SettingsTile(
          icon: PiconsRegular.currencyCircleDollar,
          title: settingsT.currency,
          subtitle: '${currency.displayName} (${currency.symbol.trim()})',
          onTap: () => _openCurrency(context),
        ),
        SettingsTile(
          icon: PiconsRegular.hash,
          title: settingsT.numberFormat.title,
          // A live sample shows the current format at a glance.
          subtitle: CurrencyFormatter.format(NumberFormatView.previewAmount),
          onTap: () => _openNumberFormat(context),
        ),
        SettingsTile(
          icon: PiconsRegular.textAa,
          title: settingsT.fontSize.title,
          subtitle: (settings?.fontSize ?? AppFontSize.defaultSize).displayName,
          onTap: () => _openFontSize(context),
        ),
        SettingsTile(
          icon: PiconsRegular.sun,
          title: settingsT.appearance,
          subtitle: AppearanceView.labelFor(theme),
          onTap: () => _openAppearance(context),
        ),
        SettingsTile(
          icon: PiconsRegular.calendarBlank,
          title: settingsT.calendar.title,
          subtitle: settingsT.calendar.rowSubtitle(day: firstDay.displayName),
          onTap: () => _openCalendar(context),
        ),
      ],
    );
  }

  Widget _notificationsSection(BuildContext context, UserSettings? settings) {
    final settingsT = t.settings;

    return SettingsSection(
      title: settingsT.sections.notifications,
      children: [
        SettingsTile(
          icon: PiconsRegular.bell,
          title: settingsT.notifications.title,
          subtitle: _notificationsSummary(settings),
          onTap: () => _openNotifications(context),
        ),
      ],
    );
  }

  Widget _dataSection(BuildContext context) {
    final settingsT = t.settings;
    final recurringT = settingsT.recurring;
    final exportT = settingsT.export;

    return SettingsSection(
      title: settingsT.sections.dataBudget,
      children: [
        SettingsTile(
          icon: PiconsRegular.repeat,
          title: recurringT.title,
          subtitle: recurringT.subtitle,
          onTap: () => context.push(SettingsRoute.recurring.location),
        ),
        SettingsTile(
          icon: PiconsRegular.export,
          title: exportT.title,
          subtitle: exportT.rowSubtitle,
          onTap: () => context.push(SettingsRoute.export.location),
        ),
      ],
    );
  }

  Widget _automationSection(BuildContext context) {
    final settingsT = t.settings;
    final commonT = t.common;

    return SettingsSection(
      title: settingsT.sections.automation,
      children: [
        SettingsTile(
          icon: PiconsRegular.chatText,
          title: commonT.autoImport,
          subtitle: settingsT.autoImportSubtitle,
          onTap: () => context.push(SettingsRoute.autoImport.location),
        ),
        SettingsTile(
          icon: PiconsRegular.funnel,
          title: commonT.matchingRules,
          subtitle: settingsT.matchingRulesSubtitle,
          onTap: () => context.push(SettingsRoute.matchingRules.location),
        ),
      ],
    );
  }

  Widget _generalSection(BuildContext context, UserSettings? settings) {
    final settingsT = t.settings;
    final languageCode = settings?.languageCode ?? 'system';

    return SettingsSection(
      title: settingsT.sections.general,
      children: [
        SettingsTile(
          icon: PiconsRegular.translate,
          title: settingsT.language.title,
          subtitle: LanguageView.labelFor(languageCode),
          onTap: () => _openLanguage(context),
        ),
        SettingsTile(
          icon: AppRootTab.home.icon,
          title: settingsT.homePage.title,
          subtitle: HomePageSettingsView.optionFor(
            settings?.homeTab ?? AppRootTab.home,
          ).title,
          onTap: () => _openHomePage(context),
        ),
        SettingsTile(
          icon: PiconsRegular.tag,
          title: t.categories.settings.title,
          subtitle: t.settings.categories.rowSubtitle,
          onTap: () => _openCategories(context),
        ),
      ],
    );
  }

  Widget _supportSection(BuildContext context) {
    final settingsT = t.settings;

    return SettingsSection(
      title: settingsT.sections.support,
      children: [
        SettingsTile(
          icon: PiconsRegular.envelopeSimple,
          title: t.common.sendFeedback,
          subtitle: settingsT.feedbackSubtitle,
          onTap: () => sendFeedback(context),
        ),
      ],
    );
  }

  /// Sign out sits alone below every section, with no header.
  Widget _signOutRow(BuildContext context) {
    final isSignedIn = context.watch<AuthBloc>().state is Authenticated;
    if (!isSignedIn) return const SizedBox.shrink();

    return SettingsSection(
      title: null,
      children: [
        SettingsTile(
          icon: PiconsRegular.signOut,
          title: t.settings.signOut,
          titleColor: Theme.of(context).colorScheme.error,
          onTap: () => context.read<AuthBloc>().add(const SignOutRequested()),
        ),
      ],
    );
  }

  Widget _developerSection(BuildContext context) {
    return SettingsSection(
      title: 'Developer',
      children: [
        SettingsTile(
          icon: PiconsRegular.database,
          title: 'Database inspector',
          onTap: () => _openDbInspector(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: t.settings.title,
      leading: const AppBackButton(),
      child: BlocListener<SettingsBloc, SettingsState>(
        listenWhen: (_, s) => s is SettingsError,
        listener: SettingsStateView.showSaveFailed,
        child: BlocBuilder<SettingsBloc, SettingsState>(
          // A save's SettingsLoading must not blank the subtitles.
          buildWhen: (previous, current) =>
              current is SettingsLoaded || previous is SettingsInitial,
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
                _accountSection(context),
                _preferencesSection(context, settings),
                _notificationsSection(context, settings),
                _dataSection(context),
                _automationSection(context),
                _generalSection(context, settings),
                _supportSection(context),
                _signOutRow(context),
                if (kDebugMode) _developerSection(context),
              ],
            );
          },
        ),
      ),
    );
  }
}
