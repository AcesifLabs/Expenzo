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

  bool _hasActiveFilters(RecordLoaded state) {
    return state.filterStartDate != null ||
        state.filterEndDate != null ||
        (state.filterCategoryIds != null &&
            state.filterCategoryIds!.isNotEmpty) ||
        state.filterRecordType != null;
  }

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
    on<SearchRecords>(_onSearchRecords);
    on<ApplyFilters>(_onApplyFilters);
    on<ClearFilters>(_onClearFilters);
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
    final currentQuery = state is RecordLoaded
        ? (state as RecordLoaded).searchQuery
        : '';

    emit(
      RecordLoaded(
        records: records,
        total: records.length,
        hasMore: records.length >= _pageSize,
        searchQuery: currentQuery,
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

    if (_hasActiveFilters(currentState)) {
      // Filtered pagination: use getFilteredRecords with offset
      final result = await recordRepository.getFilteredRecords(
        startDate: currentState.filterStartDate,
        endDate: currentState.filterEndDate,
        categoryIds: currentState.filterCategoryIds,
        recordType: currentState.filterRecordType,
        limit: _pageSize,
        offset: currentState.records.length,
      );

      result.fold((failure) => emit(RecordError(failure.message)), (
        newRecords,
      ) {
        final allRecords = [...currentState.records, ...newRecords];
        emit(
          currentState.copyWith(
            records: allRecords,
            total: allRecords.length,
            hasMore: newRecords.length >= _pageSize,
          ),
        );
      });
    } else {
      // Normal pagination: use getRecords
      final result = await getRecords(
        GetRecordsParams(limit: _pageSize, offset: currentState.records.length),
      );

      result.fold((failure) => emit(RecordError(failure.message)), (
        newRecords,
      ) {
        final allRecords = [...currentState.records, ...newRecords];
        emit(
          RecordLoaded(
            records: allRecords,
            total: allRecords.length,
            hasMore: newRecords.length >= _pageSize,
            searchQuery: currentState.searchQuery,
          ),
        );
      });
    }
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

  void _onSearchRecords(SearchRecords event, Emitter<RecordState> emit) {
    if (state is RecordLoaded) {
      emit((state as RecordLoaded).copyWith(searchQuery: event.query));
    }
  }

  Future<void> _onApplyFilters(
    ApplyFilters event,
    Emitter<RecordState> emit,
  ) async {
    final currentQuery = state is RecordLoaded
        ? (state as RecordLoaded).searchQuery
        : '';

    emit(const RecordLoading());

    // Cancel stream subscription — switch to manual filtered fetch
    await _recordsSubscription?.cancel();
    _recordsSubscription = null;

    final result = await recordRepository.getFilteredRecords(
      startDate: event.startDate,
      endDate: event.endDate,
      categoryIds: event.categoryIds,
      recordType: event.recordType,
      limit: _pageSize,
    );

    result.fold(
      (failure) => emit(RecordError(failure.message)),
      (records) => emit(
        RecordLoaded(
          records: records,
          total: records.length,
          hasMore: records.length >= _pageSize,
          searchQuery: currentQuery,
          filterStartDate: event.startDate,
          filterEndDate: event.endDate,
          filterCategoryIds: event.categoryIds,
          filterRecordType: event.recordType,
        ),
      ),
    );
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<RecordState> emit,
  ) async {
    // Reset to unfiltered: restart the reactive stream
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
