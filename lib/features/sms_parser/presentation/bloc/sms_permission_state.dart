import 'package:equatable/equatable.dart';

abstract class SmsPermissionState extends Equatable {
  const SmsPermissionState();

  @override
  List<Object?> get props => [];
}

class SmsPermissionInitial extends SmsPermissionState {
  const SmsPermissionInitial();
}

class SmsPermissionLoading extends SmsPermissionState {
  const SmsPermissionLoading();
}

class SmsPermissionGranted extends SmsPermissionState {
  const SmsPermissionGranted();
}

class SmsPermissionDenied extends SmsPermissionState {
  const SmsPermissionDenied();
}

class SmsPermissionPermanentlyDenied extends SmsPermissionState {
  const SmsPermissionPermanentlyDenied();
}

class SmsPermissionTimeout extends SmsPermissionState {
  const SmsPermissionTimeout();
}
