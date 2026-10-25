import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/constants/app_font_size.dart';
import 'package:expense_tracker/core/constants/digit_grouping.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/core/utils/number_display_format.dart';
import '../../domain/entities/user_settings.dart';

abstract class SettingsLocalDatasource {
  Future<UserSettings> getSettings();
  Future<UserSettings> updateSettings(UserSettings settings);

  /// Replaces the stored settings with the first-run defaults.
  ///
  /// Throws: [CacheException]
  Future<UserSettings> resetSettings();
}

class SettingsLocalDatasourceImpl implements SettingsLocalDatasource {
  final SharedPreferences sharedPreferences;
  static const String _settingsKey = 'user_settings';

  SettingsLocalDatasourceImpl({required this.sharedPreferences});

  @override
  Future<UserSettings> getSettings() async {
    try {
      final jsonString = sharedPreferences.getString(_settingsKey);
      if (jsonString == null) {
        final now = DateTime.now().toUtc();
        final defaultSettings = UserSettings(
          currencyCode: CurrencyConfig.defaultCode,
          emailFetchLimit: 100,
          notificationsEnabled: true,
          theme: 'system',
          languageCode: 'system',
          onboardingCompleted: false,
          createdAt: now,
          updatedAt: now,
        );

        return await updateSettings(defaultSettings);
      }
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      return _mapFromJson(json);
    } catch (e, s) {
      appLogger.error('Settings local datasource error', e, s);
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<UserSettings> resetSettings() async {
    try {
      await sharedPreferences.remove(_settingsKey);
    } catch (e, s) {
      appLogger.error('Settings local datasource error', e, s);
      throw CacheException(message: e.toString());
    }

    // With no stored settings, getSettings writes the defaults. Delete all
    // data keeps onboarding done (ADR 0010, SAAP-74).
    final defaults = await getSettings();

    return updateSettings(defaults.copyWith(onboardingCompleted: true));
  }

  @override
  Future<UserSettings> updateSettings(UserSettings settings) async {
    try {
      final json = _mapToJson(settings);
      await sharedPreferences.setString(_settingsKey, jsonEncode(json));

      return settings;
    } catch (e, s) {
      appLogger.error('Settings local datasource error', e, s);
      throw CacheException(message: e.toString());
    }
  }

  Map<String, dynamic> _mapToJson(UserSettings settings) {
    return {
      'id': settings.id,
      'currencyCode': settings.currencyCode,
      'emailFetchLimit': settings.emailFetchLimit,
      'notificationsEnabled': settings.notificationsEnabled,
      'budgetOverAlertsEnabled': settings.budgetOverAlertsEnabled,
      'budgetNearLimitAlertsEnabled': settings.budgetNearLimitAlertsEnabled,
      'weeklySummaryEnabled': settings.weeklySummaryEnabled,
      'recurringRemindersEnabled': settings.recurringRemindersEnabled,
      'theme': settings.theme,
      'languageCode': settings.languageCode,
      'autoImportPromptDismissed': settings.autoImportPromptDismissed,
      'defaultRecurringFrequency': settings.defaultRecurringFrequency,
      'recurringAutoCreate': settings.recurringAutoCreate,
      'decimalPlaces': settings.decimalPlaces,
      'digitGrouping': settings.digitGrouping.name,
      'fontSize': settings.fontSize.name,
      'firstDayOfWeek': settings.firstDayOfWeek?.name,
      'homeTab': settings.homeTab.name,
      'syncEnabled': settings.syncEnabled,
      'onboardingCompleted': settings.onboardingCompleted,
      'crashReportsEnabled': settings.crashReportsEnabled,
      'monthlyIncome': settings.monthlyIncome,
      'createdAt': settings.createdAt.toIso8601String(),
      'updatedAt': settings.updatedAt.toIso8601String(),
    };
  }

  UserSettings _mapFromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'] as int?,
      currencyCode: _currencyCodeFrom(json),
      emailFetchLimit: json['emailFetchLimit'] as int,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      budgetOverAlertsEnabled: json['budgetOverAlertsEnabled'] as bool? ?? true,
      budgetNearLimitAlertsEnabled:
          json['budgetNearLimitAlertsEnabled'] as bool? ?? true,
      weeklySummaryEnabled: json['weeklySummaryEnabled'] as bool? ?? false,
      recurringRemindersEnabled:
          json['recurringRemindersEnabled'] as bool? ?? true,
      theme: json['theme'] as String,
      languageCode: json['languageCode'] as String? ?? 'system',
      autoImportPromptDismissed:
          json['autoImportPromptDismissed'] as bool? ?? false,
      defaultRecurringFrequency:
          json['defaultRecurringFrequency'] as String? ?? 'monthly',
      recurringAutoCreate: json['recurringAutoCreate'] as bool? ?? false,
      decimalPlaces: _decimalPlacesFrom(json),
      digitGrouping:
          DigitGrouping.fromName(json['digitGrouping'] as String?) ??
          NumberDisplayFormat.defaultGrouping,
      fontSize:
          AppFontSize.fromName(json['fontSize'] as String?) ??
          AppFontSize.defaultSize,
      firstDayOfWeek: FirstDayOfWeek.fromName(
        json['firstDayOfWeek'] as String?,
      ),
      homeTab: AppRootTab.fromName(json['homeTab'] as String?),
      syncEnabled: json['syncEnabled'] as bool? ?? true,
      // A missing key stays null on purpose: ResolveOnboardingStatus decides.
      onboardingCompleted: json['onboardingCompleted'] as bool?,
      crashReportsEnabled: json['crashReportsEnabled'] as bool? ?? true,
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Older versions stored only a free-text symbol (default '\$').
  String _currencyCodeFrom(Map<String, dynamic> json) {
    final code = json['currencyCode'];
    if (code is String) return code;
    final legacySymbol = json['currencySymbol'];
    if (legacySymbol is String) {
      return CurrencyConfig.codeForLegacySymbol(legacySymbol);
    }

    return CurrencyConfig.defaultCode;
  }

  // Missing before SAAP-65; anything outside the allowed values reads as the
  // default.
  int _decimalPlacesFrom(Map<String, dynamic> json) {
    final places = json['decimalPlaces'];
    if (places is int &&
        NumberDisplayFormat.allowedDecimalPlaces.contains(places)) {
      return places;
    }

    return NumberDisplayFormat.defaultDecimalPlaces;
  }
}
