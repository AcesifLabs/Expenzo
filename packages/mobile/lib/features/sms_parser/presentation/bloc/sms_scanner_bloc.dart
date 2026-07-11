import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import '../../domain/entities/sms_scan_result_item.dart';
import '../../domain/usecases/scan_sms_usecase.dart';
import 'package:expense_tracker/features/records/domain/usecases/create_records_from_parsed_list.dart';
import 'sms_scanner_event.dart';
import 'sms_scanner_submission_status.dart';
import 'sms_scanner_state.dart';

const _scanPageSize = 10;

class SmsScannerBloc extends Bloc<SmsScannerEvent, SmsScannerState> {
  final ScanSmsUseCase scanSmsUseCase;
  final RecordRepository recordRepository;
  final CreateRecordsFromParsedList createRecordsFromParsedList;
  final GetBudgetsWithProgress getBudgetsWithProgress;

  SmsScannerBloc({
    required this.scanSmsUseCase,
    required this.recordRepository,
    required this.createRecordsFromParsedList,
    required this.getBudgetsWithProgress,
  }) : super(SmsScannerInitial()) {
    on<StartScan>(_onStartScan, transformer: droppable());
    on<LoadMoreScanResults>(_onLoadMore, transformer: concurrent());
    on<ToggleSelection>(_onToggleSelection, transformer: concurrent());
    on<SelectAll>(_onSelectAll, transformer: concurrent());
    on<DeselectAll>(_onDeselectAll, transformer: concurrent());
    on<SelectSenderGroup>(_onSelectSenderGroup, transformer: concurrent());
    on<DeselectSenderGroup>(_onDeselectSenderGroup, transformer: concurrent());
    on<SetViewMode>(_onSetViewMode, transformer: concurrent());
    on<ClearResults>(_onClearResults, transformer: concurrent());
    on<CreateSelectedExpenses>(
      _onCreateSelectedExpenses,
      transformer: concurrent(),
    );
  }

  Future<void> _onStartScan(
    StartScan event,
    Emitter<SmsScannerState> emit,
  ) async {
    emit(const SmsScannerScanning(processedMessages: 0, totalMessages: 0));

    final scanResult = await scanSmsUseCase(
      ScanSmsParams(
        startDate: event.startDate,
        endDate: event.endDate,
        offset: 0,
        limit: _scanPageSize,
      ),
    );

    await scanResult.fold(
      (failure) async => emit(SmsScannerError(message: failure.message)),
      (page) async {
        if (page.results.isEmpty) {
          _emitEmptyResults(emit, event);

          return;
        }

        final finalResults = await _filterDuplicates(
          page.results,
          event.filterDuplicates,
        );

        emit(
          SmsScannerScanComplete(
            results: finalResults,
            selectedIds: finalResults.map((t) => t.sourceId).toSet(),
            lastScanTimestamp: DateTime.now(),
            currentOffset: page.nextOffset,
            hasReachedMax: page.hasReachedMax,
            startDate: event.startDate,
            endDate: event.endDate,
            submissionStatus: SmsScannerSubmissionStatus.idle,
            submissionErrorMessage: null,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMore(
    LoadMoreScanResults event,
    Emitter<SmsScannerState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SmsScannerScanComplete) return;
    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await scanSmsUseCase(
      ScanSmsParams(
        startDate: currentState.startDate,
        endDate: currentState.endDate,
        offset: currentState.currentOffset,
        limit: _scanPageSize,
      ),
    );

    await result.fold(
      (failure) async => emit(SmsScannerError(message: failure.message)),
      (page) async {
        final newFiltered = await _filterDuplicates(
          page.results,
          event.filterDuplicates,
        );
        final allResults = [...currentState.results, ...newFiltered];

        emit(
          currentState.copyWith(
            results: allResults,
            selectedIds: {...currentState.selectedIds}
              ..addAll(newFiltered.map((t) => t.sourceId)),
            currentOffset: page.nextOffset,
            hasReachedMax: page.hasReachedMax,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  void _onToggleSelection(
    ToggleSelection event,
    Emitter<SmsScannerState> emit,
  ) {
    final currentState = state;
    if (currentState is SmsScannerScanComplete) {
      final newSelectedIds = Set<String>.from(currentState.selectedIds);
      if (newSelectedIds.contains(event.transactionId)) {
        newSelectedIds.remove(event.transactionId);
      } else {
        newSelectedIds.add(event.transactionId);
      }
      emit(
        currentState.copyWith(
          selectedIds: newSelectedIds,
          clearSubmissionErrorMessage: true,
        ),
      );
    }
  }

  void _onSelectAll(SelectAll event, Emitter<SmsScannerState> emit) {
    final currentState = state;
    if (currentState is SmsScannerScanComplete) {
      final allIds = currentState.results.map((r) => r.sourceId).toSet();
      emit(
        currentState.copyWith(
          selectedIds: allIds,
          clearSubmissionErrorMessage: true,
        ),
      );
    }
  }

  void _onDeselectAll(DeselectAll event, Emitter<SmsScannerState> emit) {
    final currentState = state;
    if (currentState is SmsScannerScanComplete) {
      emit(
        currentState.copyWith(
          selectedIds: {},
          clearSubmissionErrorMessage: true,
        ),
      );
    }
  }

  void _onSelectSenderGroup(
    SelectSenderGroup event,
    Emitter<SmsScannerState> emit,
  ) {
    final currentState = state;
    if (currentState is SmsScannerScanComplete) {
      emit(
        currentState.copyWith(
          selectedIds: {...currentState.selectedIds}
            ..addAll(currentState.sourceIdsForSender(event.senderKey)),
          clearSubmissionErrorMessage: true,
        ),
      );
    }
  }

  void _onDeselectSenderGroup(
    DeselectSenderGroup event,
    Emitter<SmsScannerState> emit,
  ) {
    final currentState = state;
    if (currentState is SmsScannerScanComplete) {
      final nextSelectedIds = Set<String>.from(currentState.selectedIds)
        ..removeAll(currentState.sourceIdsForSender(event.senderKey));
      emit(
        currentState.copyWith(
          selectedIds: nextSelectedIds,
          clearSubmissionErrorMessage: true,
        ),
      );
    }
  }

  void _onSetViewMode(SetViewMode event, Emitter<SmsScannerState> emit) {
    final currentState = state;
    if (currentState is SmsScannerScanComplete) {
      emit(currentState.copyWith(viewMode: event.viewMode));
    }
  }

  void _onClearResults(ClearResults event, Emitter<SmsScannerState> emit) {
    emit(SmsScannerInitial());
  }

  Future<void> _onCreateSelectedExpenses(
    CreateSelectedExpenses event,
    Emitter<SmsScannerState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SmsScannerScanComplete) {
      return;
    }

    emit(
      currentState.copyWith(
        submissionStatus: SmsScannerSubmissionStatus.submitting,
        clearSubmissionErrorMessage: true,
      ),
    );

    final result = await createRecordsFromParsedList(event.transactions);

    final currentCompleteState = state;
    if (currentCompleteState is! SmsScannerScanComplete) {
      return;
    }

    result.fold(
      (failure) {
        emit(_buildFailureState(currentCompleteState, failure));
      },
      (creationResult) {
        emit(
          currentCompleteState.copyWith(
            submissionStatus: SmsScannerSubmissionStatus.success,
            clearSubmissionErrorMessage: true,
          ),
        );
        unawaited(_reloadBudgets());
      },
    );
  }

  Future<void> _reloadBudgets() async {
    try {
      await getBudgetsWithProgress();
    } catch (e, s) {
      addError(e, s);
      debugPrint('SmsScannerBloc: Failed to reload budgets: $e');
    }
  }

  void _emitEmptyResults(Emitter<SmsScannerState> emit, StartScan event) {
    emit(
      SmsScannerScanComplete(
        results: const [],
        selectedIds: const {},
        lastScanTimestamp: DateTime.now(),
        hasReachedMax: true,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );
  }

  Future<List<SmsScanResultItem>> _filterDuplicates(
    List<SmsScanResultItem> transactions,
    bool filterDuplicates,
  ) async {
    if (!filterDuplicates || transactions.isEmpty) return transactions;

    final sourceIds = transactions.map((t) => t.sourceId).toList();
    final existingIdsResult = await recordRepository.getExistingSourceIds(
      sourceIds,
    );
    final existingIds = existingIdsResult.getOrElse(() => <String>{});

    return transactions
        .where((t) => !existingIds.contains(t.sourceId))
        .toList();
  }

  SmsScannerScanComplete _buildFailureState(
    SmsScannerScanComplete currentState,
    Failure failure,
  ) {
    return currentState.copyWith(
      submissionStatus: SmsScannerSubmissionStatus.failure,
      submissionErrorMessage: failure.message,
    );
  }
}
