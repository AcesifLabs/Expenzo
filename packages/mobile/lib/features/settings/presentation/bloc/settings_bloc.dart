import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/delete_account.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/update_settings.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import 'package:expense_tracker/core/error/failure_message.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettings getSettings;
  final UpdateSettings updateSettings;
  final DeleteAccount deleteAccount;

  SettingsBloc({
    required this.getSettings,
    required this.updateSettings,
    required this.deleteAccount,
  }) : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings, transformer: concurrent());
    on<UpdateSettingsEvent>(_onUpdateSettings, transformer: concurrent());
    on<UpdateCurrency>(_onUpdateCurrency, transformer: concurrent());
    on<UpdateEmailFetchLimit>(
      _onUpdateEmailFetchLimit,
      transformer: concurrent(),
    );
    on<UpdateNotificationsEnabled>(
      _onUpdateNotificationsEnabled,
      transformer: concurrent(),
    );
    on<UpdateTheme>(_onUpdateTheme, transformer: concurrent());
    on<UpdateLanguage>(_onUpdateLanguage, transformer: concurrent());
    on<DismissAutoImportPrompt>(
      _onDismissAutoImportPrompt,
      transformer: concurrent(),
    );
    on<DeleteAccountEvent>(_onDeleteAccountEvent, transformer: concurrent());
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    final result = await getSettings(NoParams());
    result.fold(
      (failure) => emit(SettingsError(failureText(failure))),
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
      (failure) => emit(SettingsError(failureText(failure))),
      (settings) => emit(SettingsLoaded(settings)),
    );
  }

  void _onDismissAutoImportPrompt(
    DismissAutoImportPrompt event,
    Emitter<SettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      add(
        UpdateSettingsEvent(
          currentState.settings.copyWith(autoImportPromptDismissed: true),
        ),
      );
    }
  }

  void _onUpdateCurrency(UpdateCurrency event, Emitter<SettingsState> emit) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final updated = currentState.settings.copyWith(
        currencyCode: event.currencyCode,
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

  void _onUpdateLanguage(UpdateLanguage event, Emitter<SettingsState> emit) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final updated = currentState.settings.copyWith(
        languageCode: event.languageCode,
      );
      add(UpdateSettingsEvent(updated));
    }
  }

  Future<void> _onDeleteAccountEvent(
    DeleteAccountEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    final result = await deleteAccount(NoParams());
    result.fold(
      (failure) => emit(SettingsError(failureText(failure))),
      (_) => emit(const AccountDeleted()),
    );
  }
}
