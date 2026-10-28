import 'package:equatable/equatable.dart';

enum DeleteAccountStatus { idle, deleting, deleted, failed }

class DeleteAccountState extends Equatable {
  final DeleteAccountStatus status;

  final String? errorMessage;

  @override
  List<Object?> get props => [status, errorMessage];

  const DeleteAccountState({
    this.status = DeleteAccountStatus.idle,
    this.errorMessage,
  });
}
