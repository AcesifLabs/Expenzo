import 'package:equatable/equatable.dart';

sealed class SmsPermissionState extends Equatable {
  @override
  List<Object?> get props => [];

  const SmsPermissionState();
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
