import 'package:equatable/equatable.dart';
import '../../domain/entities/user_settings.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class UpdateSettingsEvent extends SettingsEvent {
  final UserSettings settings;

  const UpdateSettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

class UpdateCurrencySymbol extends SettingsEvent {
  final String currencySymbol;

  const UpdateCurrencySymbol(this.currencySymbol);

  @override
  List<Object?> get props => [currencySymbol];
}

class UpdateEmailFetchLimit extends SettingsEvent {
  final int limit;

  const UpdateEmailFetchLimit(this.limit);

  @override
  List<Object?> get props => [limit];
}

class UpdateNotificationsEnabled extends SettingsEvent {
  final bool enabled;

  const UpdateNotificationsEnabled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateTheme extends SettingsEvent {
  final String theme;

  const UpdateTheme(this.theme);

  @override
  List<Object?> get props => [theme];
}

class DeleteAccountEvent extends SettingsEvent {
  const DeleteAccountEvent();
}
