import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';

/// Creates a [UserSettings] for tests. All params optional with deterministic defaults.
UserSettings makeUserSettings({
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
  String? defaultRecurringFrequency,
  bool? recurringAutoCreate,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return UserSettings(
    id: id ?? 1,
    currencyCode: currencyCode ?? 'USD',
    emailFetchLimit: emailFetchLimit ?? 50,
    notificationsEnabled: notificationsEnabled ?? true,
    budgetOverAlertsEnabled: budgetOverAlertsEnabled ?? true,
    budgetNearLimitAlertsEnabled: budgetNearLimitAlertsEnabled ?? true,
    weeklySummaryEnabled: weeklySummaryEnabled ?? false,
    recurringRemindersEnabled: recurringRemindersEnabled ?? true,
    theme: theme ?? 'system',
    languageCode: languageCode ?? 'system',
    defaultRecurringFrequency: defaultRecurringFrequency ?? 'monthly',
    recurringAutoCreate: recurringAutoCreate ?? false,
    createdAt: createdAt ?? DateTime(2024, 1, 1),
    updatedAt: updatedAt ?? DateTime(2024, 1, 1),
  );
}
