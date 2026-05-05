import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sms_permission_event.dart';
import 'sms_permission_state.dart';

class SmsPermissionBloc extends Bloc<SmsPermissionEvent, SmsPermissionState> {
  static const String _smsPermissionAskedKey = 'sms_permission_asked';
  static const String _smsPermissionStatusKey = 'sms_permission_status';

  Timer? _timeoutTimer;
  static const Duration _timeoutDuration = Duration(seconds: 5);

  SmsPermissionBloc() : super(const SmsPermissionInitial()) {
    on<CheckSmsPermission>(_onCheckPermission);
    on<RequestSmsPermission>(_onRequestPermission);
    on<OpenAppSettings>(_onOpenSettings);
  }

  Future<void> _onCheckPermission(
    CheckSmsPermission event,
    Emitter<SmsPermissionState> emit,
  ) async {
    emit(const SmsPermissionLoading());

    final status = await Permission.sms.status;
    _emitBasedOnStatus(status, emit);
  }

  Future<void> _onRequestPermission(
    RequestSmsPermission event,
    Emitter<SmsPermissionState> emit,
  ) async {
    emit(const SmsPermissionLoading());

    // Start timeout timer
    final timeoutCompleter = Completer<SmsPermissionState>();
    _timeoutTimer = Timer(_timeoutDuration, () {
      if (!timeoutCompleter.isCompleted) {
        timeoutCompleter.complete(const SmsPermissionTimeout());
      }
    });

    try {
      final status = await Permission.sms.request();
      _timeoutTimer?.cancel();

      if (!timeoutCompleter.isCompleted) {
        timeoutCompleter.complete(_mapStatusToState(status));
      }

      await _savePermissionStatus(status);
      emit(_mapStatusToState(status));
    } catch (e) {
      _timeoutTimer?.cancel();
      emit(const SmsPermissionDenied());
    }
  }

  Future<void> _onOpenSettings(
    OpenAppSettings event,
    Emitter<SmsPermissionState> emit,
  ) async {
    await openAppSettings();
  }

  void _emitBasedOnStatus(
    PermissionStatus status,
    Emitter<SmsPermissionState> emit,
  ) {
    emit(_mapStatusToState(status));
  }

  SmsPermissionState _mapStatusToState(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return const SmsPermissionGranted();
      case PermissionStatus.denied:
        return const SmsPermissionDenied();
      case PermissionStatus.permanentlyDenied:
        return const SmsPermissionPermanentlyDenied();
      case PermissionStatus.restricted:
      case PermissionStatus.provisional:
        return const SmsPermissionDenied();
    }
  }

  Future<void> _savePermissionStatus(PermissionStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_smsPermissionAskedKey, true);

    String statusString;
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        statusString = 'granted';
        break;
      case PermissionStatus.permanentlyDenied:
        statusString = 'permanently_denied';
        break;
      default:
        statusString = 'denied';
    }

    await prefs.setString(_smsPermissionStatusKey, statusString);
  }

  @override
  Future<void> close() {
    _timeoutTimer?.cancel();
    return super.close();
  }
}
