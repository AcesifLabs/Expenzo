import 'package:equatable/equatable.dart';

abstract class SmsPermissionEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const SmsPermissionEvent();
}

class CheckSmsPermission extends SmsPermissionEvent {
  const CheckSmsPermission();
}

class RequestSmsPermission extends SmsPermissionEvent {
  const RequestSmsPermission();
}

class OpenAppSettings extends SmsPermissionEvent {
  const OpenAppSettings();
}
