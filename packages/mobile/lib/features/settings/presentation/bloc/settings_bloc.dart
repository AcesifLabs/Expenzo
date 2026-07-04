import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/update_settings.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettings getSettings;
  final UpdateSettings updateSettings;

  SettingsBloc({required this.getSettings, required this.updateSettings})
    : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings, transformer: concurrent());
    on<UpdateSettingsEvent>(_onUpdateSettings, transformer: concurrent());
    on<UpdateCurrencySymbol>(
      _onUpdateCurrencySymbol,
      transformer: concurrent(),
    );
    on<UpdateEmailFetchLimit>(
      _onUpdateEmailFetchLimit,
      transformer: concurrent(),
    );
    on<UpdateNotificationsEnabled>(
      _onUpdateNotificationsEnabled,
      transformer: concurrent(),
    );
    on<UpdateTheme>(_onUpdateTheme, transformer: concurrent());
    on<DeleteAccountEvent>(_onDeleteAccountEvent, transformer: concurrent());
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
      (settings) => emit(SettingsLoaded(settings)),
    );
  }

  void _onUpdateCurrencySymbol(
    UpdateCurrencySymbol event,
    Emitter<SettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final updated = currentState.settings.copyWith(
        currencySymbol: event.currencySymbol,
      );
      add(UpdateSettingsEvent(updated));
    }
  }

  void _onUpdateEmailFetchLimit(
    UpdateEmailFetchLimit event,
    Emitter<SettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final updated = currentState.settings.copyWith(
        emailFetchLimit: event.limit,
      );
      add(UpdateSettingsEvent(updated));
    }
  }

  void _onUpdateNotificationsEnabled(
    UpdateNotificationsEnabled event,
    Emitter<SettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final updated = currentState.settings.copyWith(
        notificationsEnabled: event.enabled,
      );
      add(UpdateSettingsEvent(updated));
    }
  }

  void _onUpdateTheme(UpdateTheme event, Emitter<SettingsState> emit) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final updated = currentState.settings.copyWith(theme: event.theme);
      add(UpdateSettingsEvent(updated));
    }
  }

  void _onDeleteAccountEvent(
    DeleteAccountEvent event,
    Emitter<SettingsState> emit,
  ) {
    emit(const SettingsLoading());
    // Account deletion would call a remote API here
    // For now, emit an informative state
    emit(const SettingsError('Account deletion not yet implemented'));
  }
}
