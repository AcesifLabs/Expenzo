import 'package:equatable/equatable.dart';

abstract class SmsPermissionEvent extends Equatable {
  const SmsPermissionEvent();

  @override
  List<Object?> get props => [];
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
