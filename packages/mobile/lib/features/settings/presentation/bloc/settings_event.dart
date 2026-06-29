import 'package:equatable/equatable.dart';
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

class UpdateCurrencySymbol extends SettingsEvent {
  final String currencySymbol;

  @override
  List<Object?> get props => [currencySymbol];

  const UpdateCurrencySymbol(this.currencySymbol);
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

class UpdateTheme extends SettingsEvent {
  final String theme;

  @override
  List<Object?> get props => [theme];

  const UpdateTheme(this.theme);
}

class DeleteAccountEvent extends SettingsEvent {
  const DeleteAccountEvent();
}
