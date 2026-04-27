import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/record.dart';
import '../../domain/repositories/record_repository.dart';
import '../../domain/usecases/add_record.dart';
import '../../domain/usecases/delete_record.dart';
import '../../domain/usecases/get_records.dart';
import '../../domain/usecases/update_record.dart';
import 'record_event.dart';
import 'record_state.dart';

const _pageSize = 50;

class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final GetRecords getRecords;
  final AddRecord addRecord;
  final UpdateRecord updateRecord;
  final DeleteRecord deleteRecord;
  final RecordRepository recordRepository;

  StreamSubscription<List<Record>>? _recordsSubscription;

  RecordBloc({
    required this.getRecords,
    required this.addRecord,
    required this.updateRecord,
    required this.deleteRecord,
    required this.recordRepository,
  }) : super(const RecordInitial()) {
    on<LoadRecords>(_onLoadRecords);
    on<LoadMoreRecords>(_onLoadMoreRecords);
    on<AddRecordEvent>(_onAddRecord);
    on<UpdateRecordEvent>(_onUpdateRecord);
    on<DeleteRecordEvent>(_onDeleteRecord);
    on<RefreshRecords>(_onRefreshRecords);
    on<_RecordsUpdated>(_onRecordsUpdated);
  }

  Future<void> _onLoadRecords(
    LoadRecords event,
    Emitter<RecordState> emit,
  ) async {
    emit(const RecordLoading());

    // Start listening to the reactive stream — DB changes auto-propagate
    await _recordsSubscription?.cancel();
    _recordsSubscription = recordRepository
        .watchRecords(limit: _pageSize)
        .listen((records) {
          if (!isClosed) {
            add(_RecordsUpdated(records));
          }
        });

    // Also do a manual fetch for the initial page load
    final result = await getRecords(const GetRecordsParams(limit: _pageSize));
    result.fold(
      (failure) => emit(RecordError(failure.message)),
      (records) => emit(
        RecordLoaded(
          records: records,
          total: records.length,
          hasMore: records.length >= _pageSize,
        ),
      ),
    );
  }

  /// Handles reactive stream updates — when DB changes (add/update/delete),
  /// this fires automatically without needing explicit reloads.
  Future<void> _onRecordsUpdated(
    _RecordsUpdated event,
    Emitter<RecordState> emit,
  ) async {
    final records = event.records;

    emit(
      RecordLoaded(
        records: records,
        total: records.length,
        hasMore: records.length >= _pageSize,
      ),
    );
  }

  Future<void> _onLoadMoreRecords(
    LoadMoreRecords event,
    Emitter<RecordState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RecordLoaded || currentState.hasMore == false) {
      return;
    }

    emit(
      RecordLoadingMore(
        currentRecords: currentState.records,
        total: currentState.total,
      ),
    );

    final result = await getRecords(
      GetRecordsParams(limit: _pageSize, offset: currentState.records.length),
    );

    result.fold((failure) => emit(RecordError(failure.message)), (newRecords) {
      final allRecords = [...currentState.records, ...newRecords];
      emit(
        RecordLoaded(
          records: allRecords,
          total: allRecords.length,
          hasMore: newRecords.length >= _pageSize,
        ),
      );
    });
  }

  Future<void> _onAddRecord(
    AddRecordEvent event,
    Emitter<RecordState> emit,
  ) async {
    final result = await addRecord(event.record);
    result.fold(
      (failure) => emit(RecordError(failure.message)),
      // No manual reload needed — stream will auto-trigger _RecordsUpdated
      (_) {},
    );
  }

  Future<void> _onUpdateRecord(
    UpdateRecordEvent event,
    Emitter<RecordState> emit,
  ) async {
    final result = await updateRecord(event.record);
    result.fold(
      (failure) => emit(RecordError(failure.message)),
      // No manual reload needed — stream will auto-trigger _RecordsUpdated
      (_) {},
    );
  }

  Future<void> _onDeleteRecord(
    DeleteRecordEvent event,
    Emitter<RecordState> emit,
  ) async {
    final result = await deleteRecord(event.id);
    result.fold(
      (failure) => emit(RecordError(failure.message)),
      // No manual reload needed — stream will auto-trigger _RecordsUpdated
      (_) {},
    );
  }

  Future<void> _onRefreshRecords(
    RefreshRecords event,
    Emitter<RecordState> emit,
  ) async {
    // Re-trigger initial load (which also re-subscribes to the stream)
    add(const LoadRecords());
  }

  @override
  Future<void> close() {
    _recordsSubscription?.cancel();
    return super.close();
  }
}

/// Internal event fired by the reactive stream subscription.
class _RecordsUpdated extends RecordEvent {
  final List<Record> records;
  const _RecordsUpdated(this.records);

  @override
  List<Object?> get props => [records];
}
