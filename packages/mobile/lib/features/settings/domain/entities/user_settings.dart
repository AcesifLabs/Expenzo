import 'package:equatable/equatable.dart';

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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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
