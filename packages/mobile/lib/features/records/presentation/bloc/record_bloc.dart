import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
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
  }

  @override
  Future<void> close() {
    _recordsSubscription?.cancel();

    return super.close();
  }

  bool _hasActiveFilters(RecordLoaded state) {
    final catIds = state.filterCategoryIds;

    return state.filterStartDate != null ||
        state.filterEndDate != null ||
        (catIds != null && catIds.isNotEmpty) ||
        state.filterRecordType != null;
  }

  Future<void> _onLoadRecords(
    LoadRecords event,
    Emitter<RecordState> emit,
  ) async {
    emit(const RecordLoading());

    await _recordsSubscription?.cancel();
    _recordsSubscription = recordRepository
        .watchRecords(limit: _pageSize)
        .listen((records) {
          if (!isClosed) {
            add(_RecordsUpdated(records));
          }
        });

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

  void _onRecordsUpdated(_RecordsUpdated event, Emitter<RecordState> emit) {
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

      return;
    }

    await _loadMoreUnfiltered(currentState, emit);
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

    result.fold((failure) => emit(RecordError(failure.message)), (newRecords) {
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

    result.fold((failure) => emit(RecordError(failure.message)), (newRecords) {
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

  Future<void> _onAddRecord(
    AddRecordEvent event,
    Emitter<RecordState> emit,
  ) async {
    final result = await addRecord(event.record);

    result.fold((failure) => emit(RecordError(failure.message)), (_) {});
  }

  Future<void> _onUpdateRecord(
    UpdateRecordEvent event,
    Emitter<RecordState> emit,
  ) async {
    final result = await updateRecord(event.record);

    result.fold((failure) => emit(RecordError(failure.message)), (_) {});
  }

  Future<void> _onDeleteRecord(
    DeleteRecordEvent event,
    Emitter<RecordState> emit,
  ) async {
    final result = await deleteRecord(event.id);

    result.fold((failure) => emit(RecordError(failure.message)), (_) {});
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
    _recordsSubscription = null;

    final result = await recordRepository.getFilteredRecords(
      RecordFilter(
        startDate: event.startDate,
        endDate: event.endDate,
        categoryIds: event.categoryIds,
        recordType: event.recordType,
        limit: _pageSize,
      ),
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

  void _onClearFilters(ClearFilters event, Emitter<RecordState> emit) {
    add(const LoadRecords());
  }
}

class _RecordsUpdated extends RecordEvent {
  final List<Record> records;

  @override
  List<Object?> get props => [records];

  const _RecordsUpdated(this.records);
}
