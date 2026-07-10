import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../../../records/domain/entities/record.dart';
import '../../../records/domain/usecases/add_record.dart';
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
  final AddRecord addRecord;

  RecurringBloc({
    required this.getRecurringList,
    required this.createRecurring,
    required this.updateRecurring,
    required this.deleteRecurring,
    required this.processRecurring,
    required this.addRecord,
  }) : super(RecurringInitial()) {
    on<LoadRecurring>(_onLoadRecurring, transformer: concurrent());
    on<CreateRecurring>(_onCreateRecurring, transformer: sequential());
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

    result.fold((failure) => emit(RecurringError(failure.message)), (
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

    result.fold((failure) => emit(RecurringError(failure.message)), (_) {
      emit(const RecurringOperationSuccess());
      add(LoadRecurring());
    });
  }

  Future<void> _onProcessRecurring(
    ProcessRecurring event,
    Emitter<RecurringState> emit,
  ) async {
    emit(RecurringLoading());

    final result = await processRecurring();

    await result.fold(
      (failure) async => emit(RecurringError(failure.message)),
      (processed) async {
        // Create expense records from processed recurrences
        var createdCount = 0;
        var failedCount = 0;

        for (final recurring in processed) {
          final record = Record(
            amount: recurring.amount,
            description: recurring.description,
            date: recurring.nextOccurrence,
            categoryId: recurring.categoryId,
            source: ExpenseSource.recurring,
            recordType: RecordType.expense,
            createdAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
          );

          final addResult = await addRecord(record);
          addResult.fold((failure) => failedCount++, (_) => createdCount++);
        }

        if (failedCount > 0) {
          emit(
            RecurringError(
              'Created $createdCount records, $failedCount failed',
            ),
          );
        } else {
          emit(const RecurringOperationSuccess());
        }
        add(LoadRecurring());
      },
    );
  }
}
