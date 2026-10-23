import 'package:equatable/equatable.dart';

sealed class DeleteAccountEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const DeleteAccountEvent();
}

/// The user confirmed the Delete account dialog.
class DeleteAccountRequested extends DeleteAccountEvent {
  const DeleteAccountRequested();
}
