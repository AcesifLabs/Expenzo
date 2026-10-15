import 'package:equatable/equatable.dart';

sealed class DeleteAllDataEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const DeleteAllDataEvent();
}

/// Loads the counts and the signed-in state.
class DeleteAllDataStarted extends DeleteAllDataEvent {
  const DeleteAllDataStarted();
}

class DeleteConfirmationChanged extends DeleteAllDataEvent {
  final String text;

  @override
  List<Object?> get props => [text];

  const DeleteConfirmationChanged(this.text);
}

class DeleteAllRequested extends DeleteAllDataEvent {
  const DeleteAllRequested();
}
