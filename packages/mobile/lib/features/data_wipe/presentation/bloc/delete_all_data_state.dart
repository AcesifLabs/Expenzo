import 'package:equatable/equatable.dart';

import '../../domain/entities/local_data_summary.dart';

enum DeleteAllDataStatus { loading, ready, deleting, done, failed }

class DeleteAllDataState extends Equatable {
  /// What the user types to confirm. Not translated: the hint asks for this
  /// exact word in every language.
  static const confirmWord = 'DELETE';

  /// Null while loading, or when counting failed (the delete still runs).
  final LocalDataSummary? summary;
  final bool isSignedIn;

  /// Signed in as a Family Admin: their Shared Budgets go for the family too.
  final bool isFamilyAdmin;
  final String confirmation;
  final DeleteAllDataStatus status;

  /// Set for [DeleteAllDataStatus.failed].
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

  /// Ready (or ready again after a failure) and the word typed exactly.
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

  /// [errorMessage] is replaced, not kept: leaving it out clears it.
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
