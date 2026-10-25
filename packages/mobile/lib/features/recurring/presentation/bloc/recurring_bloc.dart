import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../../domain/usecases/get_recurring_list.dart';
import '../../domain/usecases/create_recurring.dart' as usecase;
import '../../domain/usecases/update_recurring.dart' as usecase;
import '../../domain/usecases/delete_recurring.dart' as usecase;
import '../../domain/usecases/post_due_recurring.dart';
import '../bloc/recurring_event.dart';
import '../bloc/recurring_state.dart';
import 'package:expense_tracker/core/error/failure_message.dart';

class RecurringBloc extends Bloc<RecurringEvent, RecurringState> {
  final GetRecurringList getRecurringList;
  final usecase.CreateRecurring createRecurring;
  final usecase.UpdateRecurring updateRecurring;
  final usecase.DeleteRecurring deleteRecurring;
  final PostDueRecurring postDueRecurring;

  RecurringBloc({
    required this.getRecurringList,
    required this.createRecurring,
    required this.updateRecurring,
    required this.deleteRecurring,
    required this.postDueRecurring,
  }) : super(RecurringInitial()) {
    on<LoadRecurring>(_onLoadRecurring, transformer: concurrent());
    on<CreateRecurring>(_onCreateRecurring, transformer: droppable());
    on<UpdateRecurring>(_onUpdateRecurring, transformer: sequential());
    on<DeleteRecurring>(_onDeleteRecurring, transformer: sequential());
    on<ProcessRecurring>(_onProcessRecurring, transformer: droppable());
  }

  Future<void> _onLoadRecurring(
    LoadRecurring event,
    Emitter<RecurringState> emit,
  ) async {
    emit(RecurringLoading());

    final result = await getRecurringList(NoParams());

    result.fold(
      (failure) => emit(RecurringError(failureText(failure))),
      (recurringList) => emit(RecurringLoaded(recurringList)),
    );
  }

  Future<void> _onCreateRecurring(
    CreateRecurring event,
    Emitter<RecurringState> emit,
  ) async {
    emit(RecurringLoading());

    final result = await createRecurring(event.recurring);

    result.fold((failure) => emit(RecurringError(failureText(failure))), (
      recurring,
    ) {
      emit(const RecurringOperationSuccess());
      add(LoadRecurring());
    });
  }

  Future<void> _onUpdateRecurring(
    UpdateRecurring event,
    Emitter<RecurringState> emit,
  ) async {
    emit(RecurringLoading());

    final result = await updateRecurring(event.recurring);

    result.fold((failure) => emit(RecurringError(failureText(failure))), (
      recurring,
    ) {
      emit(const RecurringOperationSuccess());
      add(LoadRecurring());
    });
  }

  Future<void> _onDeleteRecurring(
    DeleteRecurring event,
    Emitter<RecurringState> emit,
  ) async {
    emit(RecurringLoading());

    final result = await deleteRecurring(event.id);

    result.fold((failure) => emit(RecurringError(failureText(failure))), (_) {
      emit(const RecurringOperationSuccess());
      add(LoadRecurring());
    });
  }

  Future<void> _onProcessRecurring(
    ProcessRecurring event,
    Emitter<RecurringState> emit,
  ) async {
    emit(RecurringLoading());

    final result = await postDueRecurring(automatic: event.automatic);

    result.fold(
      (failure) => emit(RecurringError(failureText(failure))),
      (created) =>
          emit(RecurringProcessed(created, automatic: event.automatic)),
    );
    add(LoadRecurring());
  }
}
