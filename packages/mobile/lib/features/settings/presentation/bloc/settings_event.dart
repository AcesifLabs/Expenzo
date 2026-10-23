import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/constants/app_font_size.dart';
import 'package:expense_tracker/core/constants/digit_grouping.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/core/router/app_root_tab.dart';
import '../../domain/entities/notification_toggle.dart';
import '../../domain/entities/user_settings.dart';

abstract class SettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const SettingsEvent();
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class UpdateSettingsEvent extends SettingsEvent {
  final UserSettings settings;

  @override
  List<Object?> get props => [settings];

  const UpdateSettingsEvent(this.settings);
}

class UpdateCurrency extends SettingsEvent {
  /// ISO 4217 code.
  final String currencyCode;

  @override
  List<Object?> get props => [currencyCode];

  const UpdateCurrency(this.currencyCode);
}

class UpdateEmailFetchLimit extends SettingsEvent {
  final int limit;

  @override
  List<Object?> get props => [limit];

  const UpdateEmailFetchLimit(this.limit);
}

class UpdateNotificationsEnabled extends SettingsEvent {
  final bool enabled;

  @override
  List<Object?> get props => [enabled];

  const UpdateNotificationsEnabled(this.enabled);
}

/// One of the per-kind toggles under the master switch.
class UpdateNotificationToggle extends SettingsEvent {
  final NotificationToggle toggle;
  final bool enabled;

  @override
  List<Object?> get props => [toggle, enabled];

  const UpdateNotificationToggle(this.toggle, this.enabled);
}

class UpdateTheme extends SettingsEvent {
  final String theme;

  @override
  List<Object?> get props => [theme];

  const UpdateTheme(this.theme);
}

class UpdateLanguage extends SettingsEvent {
  /// 'system' or a locale code ('en', 'bn').
  final String languageCode;

  @override
  List<Object?> get props => [languageCode];

  const UpdateLanguage(this.languageCode);
}

class UpdateDefaultRecurringFrequency extends SettingsEvent {
  /// 'weekly', 'monthly' or 'yearly'.
  final String frequency;

  @override
  List<Object?> get props => [frequency];

  const UpdateDefaultRecurringFrequency(this.frequency);
}

class UpdateRecurringAutoCreate extends SettingsEvent {
  final bool enabled;

  @override
  List<Object?> get props => [enabled];

  const UpdateRecurringAutoCreate(this.enabled);
}

/// Changes only the fields that are given.
class UpdateNumberFormat extends SettingsEvent {
  final int? decimalPlaces;
  final DigitGrouping? digitGrouping;

  @override
  List<Object?> get props => [decimalPlaces, digitGrouping];

  const UpdateNumberFormat({this.decimalPlaces, this.digitGrouping});
}

class UpdateFontSize extends SettingsEvent {
  final AppFontSize fontSize;

  @override
  List<Object?> get props => [fontSize];

  const UpdateFontSize(this.fontSize);
}

/// Stores the choice, so it no longer follows the app language.
class UpdateFirstDayOfWeek extends SettingsEvent {
  final FirstDayOfWeek firstDayOfWeek;

  @override
  List<Object?> get props => [firstDayOfWeek];

  const UpdateFirstDayOfWeek(this.firstDayOfWeek);
}

/// Takes effect at the next cold start.
class UpdateHomeTab extends SettingsEvent {
  final AppRootTab homeTab;

  @override
  List<Object?> get props => [homeTab];

  const UpdateHomeTab(this.homeTab);
}

/// Applied to the sync engine by `ExpenzoApp` when the setting changes.
class UpdateSyncEnabled extends SettingsEvent {
  final bool enabled;

  @override
  List<Object?> get props => [enabled];

  const UpdateSyncEnabled({required this.enabled});
}

class DismissAutoImportPrompt extends SettingsEvent {
  const DismissAutoImportPrompt();
}
