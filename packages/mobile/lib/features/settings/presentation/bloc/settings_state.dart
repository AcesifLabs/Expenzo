import 'package:equatable/equatable.dart';
import '../../domain/entities/user_settings.dart';

sealed class SettingsState extends Equatable {
  @override
  List<Object?> get props => [];

  const SettingsState();
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final UserSettings settings;

  @override
  List<Object?> get props => [settings];

  const SettingsLoaded(this.settings);

  SettingsLoaded copyWith({UserSettings? settings}) {
    return SettingsLoaded(settings ?? this.settings);
  }
}

class SettingsError extends SettingsState {
  final String message;

  @override
  List<Object?> get props => [message];

  const SettingsError(this.message);
}

class SettingsUpdateSuccess extends SettingsState {
  final UserSettings settings;

  @override
  List<Object?> get props => [settings];

  const SettingsUpdateSuccess(this.settings);

  SettingsUpdateSuccess copyWith({UserSettings? settings}) {
    return SettingsUpdateSuccess(settings ?? this.settings);
  }
}

class AccountDeleted extends SettingsState {
  const AccountDeleted();
}
