import 'package:equatable/equatable.dart';

import '../../domain/entities/local_data_summary.dart';

enum DeleteAllDataStatus { loading, ready, deleting, done, failed }

class DeleteAllDataState extends Equatable {
  static const confirmWord = 'DELETE';

  final LocalDataSummary? summary;
  final bool isSignedIn;

  final bool isFamilyAdmin;
  final String confirmation;
  final DeleteAllDataStatus status;

  final String? errorMessage;

  @override
  List<Object?> get props => [
    summary,
    isSignedIn,
    isFamilyAdmin,
    confirmation,
    status,
    errorMessage,
  ];

  bool get canDelete =>
      (status == DeleteAllDataStatus.ready ||
          status == DeleteAllDataStatus.failed) &&
      confirmation.trim() == confirmWord;

  const DeleteAllDataState({
    this.summary,
    this.isSignedIn = false,
    this.isFamilyAdmin = false,
    this.confirmation = '',
    this.status = DeleteAllDataStatus.loading,
    this.errorMessage,
  });

  DeleteAllDataState copyWith({
    LocalDataSummary? summary,
    bool? isSignedIn,
    bool? isFamilyAdmin,
    String? confirmation,
    DeleteAllDataStatus? status,
    String? errorMessage,
  }) {
    return DeleteAllDataState(
      summary: summary ?? this.summary,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      isFamilyAdmin: isFamilyAdmin ?? this.isFamilyAdmin,
      confirmation: confirmation ?? this.confirmation,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}
