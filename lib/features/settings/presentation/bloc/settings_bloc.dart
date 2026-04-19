import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/usecase.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/update_settings.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettings getSettings;
  final UpdateSettings updateSettings;

  SettingsBloc({required this.getSettings, required this.updateSettings})
    : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateSettingsEvent>(_onUpdateSettings);
    on<UpdateCurrencySymbol>(_onUpdateCurrencySymbol);
    on<UpdateEmailFetchLimit>(_onUpdateEmailFetchLimit);
    on<UpdateNotificationsEnabled>(_onUpdateNotificationsEnabled);
    on<UpdateTheme>(_onUpdateTheme);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    final result = await getSettings(NoParams());
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (settings) => emit(SettingsLoaded(settings)),
    );
  }

  Future<void> _onUpdateSettings(
    UpdateSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    final result = await updateSettings(event.settings);
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (settings) => emit(SettingsUpdateSuccess(settings)),
    );
  }

  Future<void> _onUpdateCurrencySymbol(
    UpdateCurrencySymbol event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final updated = currentState.settings.copyWith(
        currencySymbol: event.currencySymbol,
      );
      add(UpdateSettingsEvent(updated));
    }
  }

  Future<void> _onUpdateEmailFetchLimit(
    UpdateEmailFetchLimit event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final updated = currentState.settings.copyWith(
        emailFetchLimit: event.limit,
      );
      add(UpdateSettingsEvent(updated));
    }
  }

  Future<void> _onUpdateNotificationsEnabled(
    UpdateNotificationsEnabled event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final updated = currentState.settings.copyWith(
        notificationsEnabled: event.enabled,
      );
      add(UpdateSettingsEvent(updated));
    }
  }

  Future<void> _onUpdateTheme(
    UpdateTheme event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final updated = currentState.settings.copyWith(theme: event.theme);
      add(UpdateSettingsEvent(updated));
    }
  }
}
