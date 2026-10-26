import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../domain/usecases/delete_account_and_data.dart';
import 'delete_account_event.dart';
import 'delete_account_state.dart';

class DeleteAccountBloc extends Bloc<DeleteAccountEvent, DeleteAccountState> {
  final DeleteAccountAndData deleteAccountAndData;

  DeleteAccountBloc({required this.deleteAccountAndData})
    : super(const DeleteAccountState()) {
    on<DeleteAccountRequested>(_onRequested, transformer: droppable());
  }

  Future<void> _onRequested(
    DeleteAccountRequested event,
    Emitter<DeleteAccountState> emit,
  ) async {
    if (state.status == DeleteAccountStatus.deleting) return;
    emit(const DeleteAccountState(status: DeleteAccountStatus.deleting));
    final Either<Failure, Unit> result;
    try {
      result = await deleteAccountAndData(NoParams());
    } catch (e, s) {
      appLogger.error('Delete account threw', e, s);
      emit(
        DeleteAccountState(
          status: DeleteAccountStatus.failed,
          errorMessage: t.common.errors.generic,
        ),
      );

      return;
    }
    emit(
      result.fold(
        (failure) => DeleteAccountState(
          status: DeleteAccountStatus.failed,
          errorMessage: failureText(failure),
        ),
        (_) => const DeleteAccountState(status: DeleteAccountStatus.deleted),
      ),
    );
  }
}
