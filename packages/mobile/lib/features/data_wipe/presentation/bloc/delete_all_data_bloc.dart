import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../domain/repositories/data_wipe_repository.dart';
import '../../domain/usecases/delete_all_data.dart';
import '../../domain/usecases/get_local_data_summary.dart';
import 'delete_all_data_event.dart';
import 'delete_all_data_state.dart';

class DeleteAllDataBloc extends Bloc<DeleteAllDataEvent, DeleteAllDataState> {
  final GetLocalDataSummary getSummary;
  final DataWipeRepository repository;
  final DeleteAllData deleteAllData;

  final bool Function() isFamilyAdmin;

  DeleteAllDataBloc({
    required this.getSummary,
    required this.repository,
    required this.deleteAllData,
    bool Function()? isFamilyAdmin,
  }) : isFamilyAdmin = isFamilyAdmin ?? _never,
       super(const DeleteAllDataState()) {
    on<DeleteAllDataStarted>(_onStarted);
    on<DeleteConfirmationChanged>(_onConfirmationChanged);
    on<DeleteAllRequested>(_onRequested, transformer: droppable());
  }

  Future<void> _onStarted(
    DeleteAllDataStarted event,
    Emitter<DeleteAllDataState> emit,
  ) async {
    emit(state.copyWith(status: DeleteAllDataStatus.loading));
    final signedIn = await repository.isSignedIn();
    final summary = await getSummary(NoParams());

    emit(
      DeleteAllDataState(
        summary: summary.fold((_) => null, (value) => value),
        isSignedIn: signedIn,
        isFamilyAdmin: signedIn && isFamilyAdmin(),
        confirmation: state.confirmation,
        status: DeleteAllDataStatus.ready,
      ),
    );
  }

  void _onConfirmationChanged(
    DeleteConfirmationChanged event,
    Emitter<DeleteAllDataState> emit,
  ) {
    emit(
      state.copyWith(
        confirmation: event.text,
        errorMessage: state.errorMessage,
      ),
    );
  }

  Future<void> _onRequested(
    DeleteAllRequested event,
    Emitter<DeleteAllDataState> emit,
  ) async {
    if (!state.canDelete) return;
    emit(state.copyWith(status: DeleteAllDataStatus.deleting));
    final Either<Failure, Unit> result;
    try {
      result = await deleteAllData(NoParams());
    } catch (e, s) {
      appLogger.error('Delete all data threw', e, s);
      emit(
        state.copyWith(
          status: DeleteAllDataStatus.failed,
          errorMessage: t.common.errors.generic,
        ),
      );

      return;
    }
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: DeleteAllDataStatus.failed,
          errorMessage: _messageFor(failure),
        ),
        (_) => state.copyWith(status: DeleteAllDataStatus.done),
      ),
    );
  }

  static String _messageFor(Failure failure) =>
      failure is NetworkFailure || failure is ServerFailure
      ? t.settings.deleteData.serverFailed
      : failureText(failure);

  static bool _never() => false;
}
