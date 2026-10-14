import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/constants/app_font_size.dart';
import 'package:expense_tracker/core/constants/digit_grouping.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/core/utils/number_display_format.dart';

import 'notification_toggle.dart';

class UserSettings extends Equatable {
  final int? id;

  /// ISO 4217 code, see `CurrencyConfig`.
  final String currencyCode;
  final int emailFetchLimit;

  /// Master switch; the four toggles below only apply while it is on.
  final bool notificationsEnabled;
  final bool budgetOverAlertsEnabled;
  final bool budgetNearLimitAlertsEnabled;
  final bool weeklySummaryEnabled;
  final bool recurringRemindersEnabled;
  final String theme;

  /// 'system' follows the device language; otherwise a locale code ('en', 'bn').
  final String languageCode;

  /// True once the user dismissed the Home "Set up auto-import" card.
  final bool autoImportPromptDismissed;

  /// Frequency preselected for new recurring items: 'weekly', 'monthly'
  /// or 'yearly' (a `RecurringFrequency` name).
  final String defaultRecurringFrequency;

  /// When true, due recurring items become Records on app open/resume.
  final bool recurringAutoCreate;

  /// Decimals shown in amounts, one of
  /// [NumberDisplayFormat.allowedDecimalPlaces]. Display only: stored amounts
  /// keep cents (SAAP-65).
  final int decimalPlaces;
  final DigitGrouping digitGrouping;

  /// Multiplies the device text scale; see [AppFontSize].
  final AppFontSize fontSize;

  /// Null until the user picks; read [effectiveFirstDayOfWeek] instead.
  final FirstDayOfWeek? firstDayOfWeek;

  /// Root tab opened on cold start (SAAP-68).
  final AppRootTab homeTab;
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      currencyCode: currencyCode ?? this.currencyCode,
      emailFetchLimit: emailFetchLimit ?? this.emailFetchLimit,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      budgetOverAlertsEnabled:
          budgetOverAlertsEnabled ?? this.budgetOverAlertsEnabled,
      budgetNearLimitAlertsEnabled:
          budgetNearLimitAlertsEnabled ?? this.budgetNearLimitAlertsEnabled,
      weeklySummaryEnabled: weeklySummaryEnabled ?? this.weeklySummaryEnabled,
      recurringRemindersEnabled:
          recurringRemindersEnabled ?? this.recurringRemindersEnabled,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// The stored choice, else the default for [appLanguageCode] (the
  /// resolved app language, never 'system').
  FirstDayOfWeek effectiveFirstDayOfWeek(String appLanguageCode) =>
      firstDayOfWeek ?? FirstDayOfWeek.defaultFor(appLanguageCode);

  /// True when [toggle] is on and so is the master switch.
  bool isEnabled(NotificationToggle toggle) {
    if (!notificationsEnabled) return false;

    return switch (toggle) {
      NotificationToggle.budgetOver => budgetOverAlertsEnabled,
      NotificationToggle.budgetNearLimit => budgetNearLimitAlertsEnabled,
      NotificationToggle.weeklySummary => weeklySummaryEnabled,
      NotificationToggle.recurringReminders => recurringRemindersEnabled,
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
    };
  }
}
