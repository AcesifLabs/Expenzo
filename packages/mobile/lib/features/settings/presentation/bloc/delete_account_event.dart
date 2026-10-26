import 'package:equatable/equatable.dart';

sealed class DeleteAccountEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const DeleteAccountEvent();
}

class DeleteAccountRequested extends DeleteAccountEvent {
  const DeleteAccountRequested();
}
