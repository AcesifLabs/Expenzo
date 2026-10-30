import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/constants/app_font_size.dart';
import 'package:expense_tracker/core/constants/digit_grouping.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/core/utils/number_display_format.dart';

import 'notification_toggle.dart';

typedef _NotificationOverrides = ({
  bool? master,
  bool? budgetOver,
  bool? budgetNearLimit,
  bool? weeklySummary,
  bool? recurringReminders,
  bool? autoImport,
});

typedef _NotificationFlags = ({
  bool master,
  bool budgetOver,
  bool budgetNearLimit,
  bool weeklySummary,
  bool recurringReminders,
  bool autoImport,
});

class UserSettings extends Equatable {
  final int? id;

  final String currencyCode;
  final int emailFetchLimit;

  final bool notificationsEnabled;
  final bool budgetOverAlertsEnabled;
  final bool budgetNearLimitAlertsEnabled;
  final bool weeklySummaryEnabled;
  final bool recurringRemindersEnabled;
  final bool autoImportAlertsEnabled;
  final String theme;

  final String languageCode;

  final bool autoImportPromptDismissed;

  final String defaultRecurringFrequency;

  final bool recurringAutoCreate;

  final int decimalPlaces;
  final DigitGrouping digitGrouping;

  final AppFontSize fontSize;

  final FirstDayOfWeek? firstDayOfWeek;

  final AppRootTab homeTab;

  final bool syncEnabled;

  final bool? onboardingCompleted;

  final bool crashReportsEnabled;

  final double? monthlyIncome;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    currencyCode,
    emailFetchLimit,
    notificationsEnabled,
    budgetOverAlertsEnabled,
    budgetNearLimitAlertsEnabled,
    weeklySummaryEnabled,
    recurringRemindersEnabled,
    autoImportAlertsEnabled,
    theme,
    languageCode,
    autoImportPromptDismissed,
    defaultRecurringFrequency,
    recurringAutoCreate,
    decimalPlaces,
    digitGrouping,
    fontSize,
    firstDayOfWeek,
    homeTab,
    syncEnabled,
    onboardingCompleted,
    crashReportsEnabled,
    monthlyIncome,
    createdAt,
    updatedAt,
  ];

  const UserSettings({
    this.id,
    required this.currencyCode,
    required this.emailFetchLimit,
    required this.notificationsEnabled,
    this.budgetOverAlertsEnabled = true,
    this.budgetNearLimitAlertsEnabled = true,
    this.weeklySummaryEnabled = false,
    this.recurringRemindersEnabled = true,
    this.autoImportAlertsEnabled = true,
    required this.theme,
    this.languageCode = 'system',
    this.autoImportPromptDismissed = false,
    this.defaultRecurringFrequency = 'monthly',
    this.recurringAutoCreate = false,
    this.decimalPlaces = NumberDisplayFormat.defaultDecimalPlaces,
    this.digitGrouping = NumberDisplayFormat.defaultGrouping,
    this.fontSize = AppFontSize.defaultSize,
    this.firstDayOfWeek,
    this.homeTab = AppRootTab.home,
    this.syncEnabled = true,
    this.onboardingCompleted,
    this.crashReportsEnabled = true,
    this.monthlyIncome,
    required this.createdAt,
    required this.updatedAt,
  });

  UserSettings copyWith({
    int? id,
    String? currencyCode,
    int? emailFetchLimit,
    bool? notificationsEnabled,
    bool? budgetOverAlertsEnabled,
    bool? budgetNearLimitAlertsEnabled,
    bool? weeklySummaryEnabled,
    bool? recurringRemindersEnabled,
    bool? autoImportAlertsEnabled,
    String? theme,
    String? languageCode,
    bool? autoImportPromptDismissed,
    String? defaultRecurringFrequency,
    bool? recurringAutoCreate,
    int? decimalPlaces,
    DigitGrouping? digitGrouping,
    AppFontSize? fontSize,
    FirstDayOfWeek? firstDayOfWeek,
    AppRootTab? homeTab,
    bool? syncEnabled,
    bool? onboardingCompleted,
    bool? crashReportsEnabled,
    double? monthlyIncome,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final notifications = _notificationsWith((
      master: notificationsEnabled,
      budgetOver: budgetOverAlertsEnabled,
      budgetNearLimit: budgetNearLimitAlertsEnabled,
      weeklySummary: weeklySummaryEnabled,
      recurringReminders: recurringRemindersEnabled,
      autoImport: autoImportAlertsEnabled,
    ));

    return UserSettings(
      id: id ?? this.id,
      currencyCode: currencyCode ?? this.currencyCode,
      emailFetchLimit: emailFetchLimit ?? this.emailFetchLimit,
      notificationsEnabled: notifications.master,
      budgetOverAlertsEnabled: notifications.budgetOver,
      budgetNearLimitAlertsEnabled: notifications.budgetNearLimit,
      weeklySummaryEnabled: notifications.weeklySummary,
      recurringRemindersEnabled: notifications.recurringReminders,
      autoImportAlertsEnabled: notifications.autoImport,
      theme: theme ?? this.theme,
      languageCode: languageCode ?? this.languageCode,
      autoImportPromptDismissed:
          autoImportPromptDismissed ?? this.autoImportPromptDismissed,
      defaultRecurringFrequency:
          defaultRecurringFrequency ?? this.defaultRecurringFrequency,
      recurringAutoCreate: recurringAutoCreate ?? this.recurringAutoCreate,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      digitGrouping: digitGrouping ?? this.digitGrouping,
      fontSize: fontSize ?? this.fontSize,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      homeTab: homeTab ?? this.homeTab,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      crashReportsEnabled: crashReportsEnabled ?? this.crashReportsEnabled,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  FirstDayOfWeek effectiveFirstDayOfWeek(String appLanguageCode) =>
      firstDayOfWeek ?? FirstDayOfWeek.defaultFor(appLanguageCode);

  bool isEnabled(NotificationToggle toggle) {
    if (!notificationsEnabled) return false;

    return switch (toggle) {
      NotificationToggle.budgetOver => budgetOverAlertsEnabled,
      NotificationToggle.budgetNearLimit => budgetNearLimitAlertsEnabled,
      NotificationToggle.weeklySummary => weeklySummaryEnabled,
      NotificationToggle.recurringReminders => recurringRemindersEnabled,
      NotificationToggle.autoImport => autoImportAlertsEnabled,
    };
  }

  UserSettings withToggle(NotificationToggle toggle, bool enabled) {
    return switch (toggle) {
      NotificationToggle.budgetOver => copyWith(
        budgetOverAlertsEnabled: enabled,
      ),
      NotificationToggle.budgetNearLimit => copyWith(
        budgetNearLimitAlertsEnabled: enabled,
      ),
      NotificationToggle.weeklySummary => copyWith(
        weeklySummaryEnabled: enabled,
      ),
      NotificationToggle.recurringReminders => copyWith(
        recurringRemindersEnabled: enabled,
      ),
      NotificationToggle.autoImport => copyWith(
        autoImportAlertsEnabled: enabled,
      ),
    };
  }

  _NotificationFlags _notificationsWith(_NotificationOverrides overrides) {
    return (
      master: overrides.master ?? notificationsEnabled,
      budgetOver: overrides.budgetOver ?? budgetOverAlertsEnabled,
      budgetNearLimit:
          overrides.budgetNearLimit ?? budgetNearLimitAlertsEnabled,
      weeklySummary: overrides.weeklySummary ?? weeklySummaryEnabled,
      recurringReminders:
          overrides.recurringReminders ?? recurringRemindersEnabled,
      autoImport: overrides.autoImport ?? autoImportAlertsEnabled,
    );
  }
}
