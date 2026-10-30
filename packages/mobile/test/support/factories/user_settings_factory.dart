import 'package:expense_tracker/core/constants/app_font_size.dart';
import 'package:expense_tracker/core/constants/digit_grouping.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';

UserSettings makeUserSettings({
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
    id: id ?? 1,
    currencyCode: currencyCode ?? 'USD',
    emailFetchLimit: emailFetchLimit ?? 50,
    notificationsEnabled: notificationsEnabled ?? true,
    budgetOverAlertsEnabled: budgetOverAlertsEnabled ?? true,
    budgetNearLimitAlertsEnabled: budgetNearLimitAlertsEnabled ?? true,
    weeklySummaryEnabled: weeklySummaryEnabled ?? false,
    recurringRemindersEnabled: recurringRemindersEnabled ?? true,
    autoImportAlertsEnabled: autoImportAlertsEnabled ?? true,
    theme: theme ?? 'system',
    languageCode: languageCode ?? 'system',
    defaultRecurringFrequency: defaultRecurringFrequency ?? 'monthly',
    recurringAutoCreate: recurringAutoCreate ?? false,
    decimalPlaces: decimalPlaces ?? 2,
    digitGrouping: digitGrouping ?? DigitGrouping.comma,
    fontSize: fontSize ?? AppFontSize.medium,
    firstDayOfWeek: firstDayOfWeek,
    homeTab: homeTab ?? AppRootTab.home,
    createdAt: createdAt ?? DateTime(2024, 1, 1),
    updatedAt: updatedAt ?? DateTime(2024, 1, 1),
  );
}
