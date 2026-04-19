import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/usecase.dart';
import '../../domain/usecases/get_recurring_list.dart';
import '../../domain/usecases/create_recurring.dart' as usecase;
import '../../domain/usecases/update_recurring.dart' as usecase;
import '../../domain/usecases/delete_recurring.dart' as usecase;
import '../../domain/usecases/process_recurring.dart' as usecase;
import '../bloc/recurring_event.dart';
import '../bloc/recurring_state.dart';

class RecurringBloc extends Bloc<RecurringEvent, RecurringState> {
  final GetRecurringList getRecurringList;
  final usecase.CreateRecurring createRecurring;
  final usecase.UpdateRecurring updateRecurring;
  final usecase.DeleteRecurring deleteRecurring;
  final usecase.ProcessRecurring processRecurring;

  RecurringBloc({
    required this.getRecurringList,
    required this.createRecurring,
    required this.updateRecurring,
    required this.deleteRecurring,
    required this.processRecurring,
  }) : super(RecurringInitial()) {
    on<LoadRecurring>(_onLoadRecurring);
    on<CreateRecurring>(_onCreateRecurring);
    on<UpdateRecurring>(_onUpdateRecurring);
    on<DeleteRecurring>(_onDeleteRecurring);
    on<ProcessRecurring>(_onProcessRecurring);
  }

  Future<void> _onLoadRecurring(
    LoadRecurring event,
    Emitter<RecurringState> emit,
  ) async {
    emit(RecurringLoading());

    final result = await getRecurringList(NoParams());

    result.fold(
      (failure) => emit(RecurringError(failure.message)),
      (recurringList) => emit(RecurringLoaded(recurringList)),
    );
  }

  Future<void> _onCreateRecurring(
    CreateRecurring event,
    Emitter<RecurringState> emit,
  ) async {
    emit(RecurringLoading());

    final result = await createRecurring(event.recurring);

    result.fold((failure) => emit(RecurringError(failure.message)), (
      recurring,
    ) {
      emit(const RecurringOperationSuccess('Recurring transaction created'));
      add(LoadRecurring());
    });
  }

  Future<void> _onUpdateRecurring(
    UpdateRecurring event,
    Emitter<RecurringState> emit,
  ) async {
    emit(RecurringLoading());

    final result = await updateRecurring(event.recurring);

    result.fold((failure) => emit(RecurringError(failure.message)), (
      recurring,
    ) {
      emit(const RecurringOperationSuccess('Recurring transaction updated'));
      add(LoadRecurring());
    });
  }

  Future<void> _onDeleteRecurring(
    DeleteRecurring event,
    Emitter<RecurringState> emit,
  ) async {
    emit(RecurringLoading());

    final result = await deleteRecurring(event.id);

    result.fold((failure) => emit(RecurringError(failure.message)), (_) {
      emit(const RecurringOperationSuccess('Recurring transaction deleted'));
      add(LoadRecurring());
    });
  }

  Future<void> _onProcessRecurring(
    ProcessRecurring event,
    Emitter<RecurringState> emit,
  ) async {
    emit(RecurringLoading());

    final result = await processRecurring();

    result.fold((failure) => emit(RecurringError(failure.message)), (
      processed,
    ) {
      emit(
        RecurringOperationSuccess(
          'Processed $processed recurring transactions',
        ),
      );
      add(LoadRecurring());
    });
  }
}
