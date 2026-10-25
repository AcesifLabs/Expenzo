import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import '../../domain/repositories/record_repository.dart';
import '../../domain/usecases/add_record.dart';
import '../../domain/usecases/delete_record.dart';
import '../../domain/usecases/get_records.dart';
import '../../domain/usecases/update_record.dart';
import 'record_event.dart';
import 'record_state.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:dartz/dartz.dart';

const _pageSize = 50;

class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final GetRecords getRecords;
  final AddRecord addRecord;
  final UpdateRecord updateRecord;
  final DeleteRecord deleteRecord;
  final RecordRepository recordRepository;

  StreamSubscription<List<Record>>? _recordsSubscription;

  /// How many rows the live query covers: every page loaded so far, so an
  /// update never shrinks the list back to the first page.
  int _watchedLimit = _pageSize;

  RecordBloc({
    required this.getRecords,
    required this.addRecord,
    required this.updateRecord,
    required this.deleteRecord,
    required this.recordRepository,
  }) : super(const RecordInitial()) {
    on<LoadRecords>(_onLoadRecords, transformer: sequential());
    on<LoadMoreRecords>(_onLoadMoreRecords, transformer: sequential());
    on<AddRecordEvent>(_onAddRecord, transformer: sequential());
    on<UpdateRecordEvent>(_onUpdateRecord, transformer: sequential());
    on<DeleteRecordEvent>(_onDeleteRecord, transformer: sequential());
    on<RefreshRecords>(_onRefreshRecords, transformer: concurrent());
    on<SearchRecords>(_onSearchRecords, transformer: concurrent());
    on<ApplyFilters>(_onApplyFilters, transformer: concurrent());
    on<ClearFilters>(_onClearFilters, transformer: concurrent());
    on<_RecordsUpdated>(_onRecordsUpdated, transformer: concurrent());
    on<_RecordsWatchFailed>(_onRecordsWatchFailed, transformer: concurrent());
  }

  @override
  Future<void> close() {
    _recordsSubscription?.cancel();

    return super.close();
  }

  bool _hasActiveFilters(RecordLoaded state) =>
      _isFiltered(_filterOf(state, limit: _pageSize));

  Future<void> _onLoadRecords(
    LoadRecords event,
    Emitter<RecordState> emit,
  ) async {
    emit(const RecordLoading());

    await _watch(const RecordFilter(limit: _pageSize));

    final result = await getRecords(const GetRecordsParams(limit: _pageSize));
    result.fold(
      (failure) => emit(RecordError(failureText(failure))),
      (records) => emit(
        RecordLoaded(
          records: records,
          total: records.length,
          hasMore: records.length >= _pageSize,
        ),
      ),
    );
  }

  void _onRecordsUpdated(_RecordsUpdated event, Emitter<RecordState> emit) {
    final records = event.records;
    final currentState = state;
    if (currentState is! RecordLoaded) return;

    emit(
      currentState.copyWith(
        records: records,
        total: records.length,
        hasMore: records.length >= _watchedLimit,
      ),
    );
  }

  void _onRecordsWatchFailed(
    _RecordsWatchFailed event,
    Emitter<RecordState> emit,
  ) {
    emit(RecordError(failureText(event.failure)));
  }

  Future<void> _onLoadMoreRecords(
    LoadMoreRecords event,
    Emitter<RecordState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RecordLoaded || !currentState.hasMore) {
      return;
    }

    emit(
      RecordLoadingMore(
        currentRecords: currentState.records,
        total: currentState.total,
      ),
    );

    if (_hasActiveFilters(currentState)) {
      await _loadMoreFiltered(currentState, emit);
    } else {
      await _loadMoreUnfiltered(currentState, emit);
    }
    // The live query grows by a page, so it covers the new rows and any
    // added later without dropping the oldest loaded one.
    final loaded = state;
    if (loaded is RecordLoaded) {
      await _watch(_filterOf(loaded, limit: _watchedLimit + _pageSize));
    }
  }

  Future<void> _loadMoreFiltered(
    RecordLoaded currentState,
    Emitter<RecordState> emit,
  ) async {
    final result = await recordRepository.getFilteredRecords(
      RecordFilter(
        startDate: currentState.filterStartDate,
        endDate: currentState.filterEndDate,
        categoryIds: currentState.filterCategoryIds,
        recordType: currentState.filterRecordType,
        limit: _pageSize,
        offset: currentState.records.length,
      ),
    );

    result.fold((failure) => emit(RecordError(failureText(failure))), (
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
  }

  Future<void> _loadMoreUnfiltered(
    RecordLoaded currentState,
    Emitter<RecordState> emit,
  ) async {
    final result = await getRecords(
      GetRecordsParams(limit: _pageSize, offset: currentState.records.length),
    );

    result.fold((failure) => emit(RecordError(failureText(failure))), (
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
  }

  Future<void> _onAddRecord(
    AddRecordEvent event,
    Emitter<RecordState> emit,
  ) async {
    final result = await addRecord(event.record);

    result.fold(
      (failure) => emit(RecordError(failureText(failure))),
      (_) => null,
    );
  }

  Future<void> _onUpdateRecord(
    UpdateRecordEvent event,
    Emitter<RecordState> emit,
  ) async {
    final result = await updateRecord(event.record);

    result.fold(
      (failure) => emit(RecordError(failureText(failure))),
      (_) => null,
    );
  }

  Future<void> _onDeleteRecord(
    DeleteRecordEvent event,
    Emitter<RecordState> emit,
  ) async {
    final result = await deleteRecord(event.id);

    result.fold(
      (failure) => emit(RecordError(failureText(failure))),
      (_) => null,
    );
  }

  void _onRefreshRecords(RefreshRecords event, Emitter<RecordState> emit) {
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

    await _recordsSubscription?.cancel();
    final filter = RecordFilter(
      startDate: event.startDate,
      endDate: event.endDate,
      categoryIds: event.categoryIds,
      recordType: event.recordType,
      limit: _pageSize,
    );

    final result = await recordRepository.getFilteredRecords(filter);

    if (result case Right(value: final records)) {
      emit(
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
      );
      await _watch(filter);
    } else if (result case Left(value: final failure)) {
      emit(RecordError(failureText(failure)));
    }
  }

  void _onClearFilters(ClearFilters event, Emitter<RecordState> emit) {
    add(const LoadRecords());
  }

  /// [state]'s filters, reading up to [limit] rows.
  RecordFilter _filterOf(RecordLoaded state, {required int limit}) =>
      RecordFilter(
        startDate: state.filterStartDate,
        endDate: state.filterEndDate,
        categoryIds: state.filterCategoryIds,
        recordType: state.filterRecordType,
        limit: limit,
      );

  static bool _isFiltered(RecordFilter filter) {
    final catIds = filter.categoryIds;

    return filter.startDate != null ||
        filter.endDate != null ||
        (catIds != null && catIds.isNotEmpty) ||
        filter.recordType != null;
  }

  /// Follows the records [filter] selects, replacing the query followed so
  /// far. Without any filter it follows every record.
  Future<void> _watch(RecordFilter filter) async {
    await _recordsSubscription?.cancel();
    final limit = filter.limit ?? _pageSize;
    _watchedLimit = limit;
    final records = _isFiltered(filter)
        ? recordRepository.watchFilteredRecords(filter)
        : recordRepository.watchRecords(limit: limit);
    _recordsSubscription = records.listen(
      (records) {
        if (!isClosed) add(_RecordsUpdated(records));
      },
      onError: (Object e, StackTrace s) {
        appLogger.error('RecordBloc: watching records failed', e, s);
        if (!isClosed) {
          add(_RecordsWatchFailed(CacheFailure(message: e.toString())));
        }
      },
    );
  }
}

class _RecordsUpdated extends RecordEvent {
  final List<Record> records;

  @override
  List<Object?> get props => [records];

  const _RecordsUpdated(this.records);
}

class _RecordsWatchFailed extends RecordEvent {
  final CacheFailure failure;

  @override
  List<Object?> get props => [failure];

  const _RecordsWatchFailed(this.failure);
}
