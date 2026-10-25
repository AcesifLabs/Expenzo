import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/utils/number_display_format.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/update_settings.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import 'package:expense_tracker/core/error/failure_message.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettings getSettings;
  final UpdateSettings updateSettings;

  /// The newest settings: the last loaded ones plus any change still being
  /// saved. Derived events build on this, not on `state is SettingsLoaded`,
  /// so a change made while a save runs is not dropped. Null until the first
  /// load, and again after a failed save until the reload finishes.
  UserSettings? _lastLoaded;

  /// Saves still running. Saves run concurrently, so an older save's result
  /// must not replace [_lastLoaded] while a newer one built on it is pending.
  var _pendingSaves = 0;

  /// [_lastLoaded] for readers outside the bloc: unlike [state], it keeps
  /// the newest values while a save runs.
  UserSettings? get latestSettings => _lastLoaded;

  SettingsBloc({required this.getSettings, required this.updateSettings})
    : super(const SettingsInitial()) {
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
    on<UpdateNotificationToggle>(
      _onUpdateNotificationToggle,
      transformer: concurrent(),
    );
    on<UpdateTheme>(_onUpdateTheme, transformer: concurrent());
    on<UpdateLanguage>(_onUpdateLanguage, transformer: concurrent());
    on<UpdateDefaultRecurringFrequency>(
      _onUpdateDefaultRecurringFrequency,
      transformer: concurrent(),
    );
    on<UpdateRecurringAutoCreate>(
      _onUpdateRecurringAutoCreate,
      transformer: concurrent(),
    );
    on<UpdateCrashReportsEnabled>(
      _onUpdateCrashReportsEnabled,
      transformer: concurrent(),
    );
    on<UpdateNumberFormat>(_onUpdateNumberFormat, transformer: concurrent());
    on<UpdateFontSize>(_onUpdateFontSize, transformer: concurrent());
    on<UpdateFirstDayOfWeek>(
      _onUpdateFirstDayOfWeek,
      transformer: concurrent(),
    );
    on<UpdateHomeTab>(_onUpdateHomeTab, transformer: concurrent());
    on<UpdateSyncEnabled>(_onUpdateSyncEnabled, transformer: concurrent());
    on<DismissAutoImportPrompt>(
      _onDismissAutoImportPrompt,
      transformer: concurrent(),
    );
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    final result = await getSettings(NoParams());
    result.fold(
      (failure) => emit(SettingsError(failureText(failure))),
      (settings) => _emitLoaded(emit, settings),
    );
  }

  Future<void> _onUpdateSettings(
    UpdateSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    _pendingSaves++;
    emit(const SettingsLoading());
    final result = await updateSettings(event.settings);
    _pendingSaves--;
    result.fold((failure) {
      // The cached change was never stored; forget it until the reload.
      _lastLoaded = null;
      emit(SettingsError(failureText(failure)));
      add(const LoadSettings());
    }, (settings) => _emitLoaded(emit, settings));
  }

  void _onDismissAutoImportPrompt(
    DismissAutoImportPrompt event,
    Emitter<SettingsState> emit,
  ) {
    _updateFromLast((s) => s.copyWith(autoImportPromptDismissed: true));
  }

  void _onUpdateCurrency(UpdateCurrency event, Emitter<SettingsState> emit) {
    _updateFromLast((s) => s.copyWith(currencyCode: event.currencyCode));
  }

  void _onUpdateEmailFetchLimit(
    UpdateEmailFetchLimit event,
    Emitter<SettingsState> emit,
  ) {
    _updateFromLast((s) => s.copyWith(emailFetchLimit: event.limit));
  }

  void _onUpdateNotificationsEnabled(
    UpdateNotificationsEnabled event,
    Emitter<SettingsState> emit,
  ) {
    _updateFromLast((s) => s.copyWith(notificationsEnabled: event.enabled));
  }

  void _onUpdateNotificationToggle(
    UpdateNotificationToggle event,
    Emitter<SettingsState> emit,
  ) {
    _updateFromLast((s) => s.withToggle(event.toggle, event.enabled));
  }

  void _onUpdateTheme(UpdateTheme event, Emitter<SettingsState> emit) {
    _updateFromLast((s) => s.copyWith(theme: event.theme));
  }

  void _onUpdateLanguage(UpdateLanguage event, Emitter<SettingsState> emit) {
    _updateFromLast((s) => s.copyWith(languageCode: event.languageCode));
  }

  void _onUpdateDefaultRecurringFrequency(
    UpdateDefaultRecurringFrequency event,
    Emitter<SettingsState> emit,
  ) {
    _updateFromLast(
      (s) => s.copyWith(defaultRecurringFrequency: event.frequency),
    );
  }

  void _onUpdateRecurringAutoCreate(
    UpdateRecurringAutoCreate event,
    Emitter<SettingsState> emit,
  ) {
    _updateFromLast((s) => s.copyWith(recurringAutoCreate: event.enabled));
  }

  void _onUpdateCrashReportsEnabled(
    UpdateCrashReportsEnabled event,
    Emitter<SettingsState> emit,
  ) {
    _updateFromLast((s) => s.copyWith(crashReportsEnabled: event.enabled));
  }

  void _onUpdateNumberFormat(
    UpdateNumberFormat event,
    Emitter<SettingsState> emit,
  ) {
    final places = event.decimalPlaces;
    if (places != null &&
        !NumberDisplayFormat.allowedDecimalPlaces.contains(places)) {
      return;
    }
    _updateFromLast(
      (s) =>
          s.copyWith(decimalPlaces: places, digitGrouping: event.digitGrouping),
    );
  }

  void _onUpdateFontSize(UpdateFontSize event, Emitter<SettingsState> emit) {
    _updateFromLast((s) => s.copyWith(fontSize: event.fontSize));
  }

  void _onUpdateFirstDayOfWeek(
    UpdateFirstDayOfWeek event,
    Emitter<SettingsState> emit,
  ) {
    _updateFromLast((s) => s.copyWith(firstDayOfWeek: event.firstDayOfWeek));
  }

  void _onUpdateHomeTab(UpdateHomeTab event, Emitter<SettingsState> emit) {
    _updateFromLast((s) => s.copyWith(homeTab: event.homeTab));
  }

  void _onUpdateSyncEnabled(
    UpdateSyncEnabled event,
    Emitter<SettingsState> emit,
  ) {
    _updateFromLast((s) => s.copyWith(syncEnabled: event.enabled));
  }

  /// Emits [settings] once no newer save is pending, so the UI never steps
  /// back to an older value.
  void _emitLoaded(Emitter<SettingsState> emit, UserSettings settings) {
    if (_pendingSaves > 0) return;
    _lastLoaded = settings;
    emit(SettingsLoaded(settings));
  }

  /// Saves [change] applied to the newest settings. Does nothing before the
  /// first load.
  void _updateFromLast(UserSettings Function(UserSettings) change) {
    final last = _lastLoaded;
    if (last == null) return;
    final updated = change(last);
    _lastLoaded = updated;
    add(UpdateSettingsEvent(updated));
  }
}
