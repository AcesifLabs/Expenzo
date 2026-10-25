import 'dart:async';

import 'package:dartz/dartz.dart' show Either, Left, Right;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
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
import 'package:expense_tracker/core/error/failure_message.dart';

const _scanPageSize = 10;

class SmsScannerBloc extends Bloc<SmsScannerEvent, SmsScannerState> {
  final ScanSmsUseCase scanSmsUseCase;
  final RecordRepository recordRepository;
  final CreateRecordsFromParsedList createRecordsFromParsedList;
  final GetBudgetsWithProgress getBudgetsWithProgress;

  /// Amounts within half a cent are the same money (ADR-0014).
  static const _amountTolerance = 0.005;

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
      transformer: droppable(),
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
      (failure) async => emit(SmsScannerError(message: failureText(failure))),
      (page) async {
        if (page.results.isEmpty) {
          _emitEmptyResults(emit, event);

          return;
        }

        final filtered = await _filterDuplicates(
          page.results,
          event.filterDuplicates,
        );
        final lookupFailure = filtered.fold((f) => f, (_) => null);
        if (lookupFailure != null) {
          emit(SmsScannerError(message: failureText(lookupFailure)));

          return;
        }
        final finalResults = filtered.getOrElse(() => const []);

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
      (failure) async => emit(SmsScannerError(message: failureText(failure))),
      (page) async {
        final filtered = await _filterDuplicates(
          page.results,
          event.filterDuplicates,
        );
        final lookupFailure = filtered.fold((f) => f, (_) => null);
        if (lookupFailure != null) {
          emit(SmsScannerError(message: failureText(lookupFailure)));

          return;
        }
        final newFiltered = filtered.getOrElse(() => const []);
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
      appLogger.error('SmsScannerBloc: Failed to reload budgets', e, s);
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

  /// [transactions] without the messages already imported. A failed
  /// lookup is an error: showing every message as new would let the user
  /// import them all again.
  Future<Either<Failure, List<SmsScanResultItem>>> _filterDuplicates(
    List<SmsScanResultItem> transactions,
    bool filterDuplicates,
  ) async {
    if (!filterDuplicates || transactions.isEmpty) return Right(transactions);

    final existing = await recordRepository.getExistingSourceIds([
      for (final t in transactions) t.sourceId,
    ]);
    final unseen = existing.map(
      (ids) => transactions.where((t) => !ids.contains(t.sourceId)).toList(),
    );

    return unseen.fold((failure) async => Left(failure), _withoutLegacyImports);
  }

  /// [transactions] without messages imported before database v20 under
  /// their old scan id. That id is a 30-bit hash other messages can share,
  /// so the stored record must also have the same amount.
  Future<Either<Failure, List<SmsScanResultItem>>> _withoutLegacyImports(
    List<SmsScanResultItem> transactions,
  ) async {
    final legacyIds = [for (final t in transactions) ?t.legacySourceId];
    if (legacyIds.isEmpty) return Right(transactions);
    final stored = await recordRepository.getAmountsBySourceIds(legacyIds);

    return stored.map(
      (amounts) => transactions.where((t) {
        final amount = t.parsedTransaction.amount?.abs();
        final candidates = amounts[t.legacySourceId] ?? const <double>[];

        return amount == null ||
            !candidates.any((c) => (c - amount).abs() < _amountTolerance);
      }).toList(),
    );
  }

  SmsScannerScanComplete _buildFailureState(
    SmsScannerScanComplete currentState,
    Failure failure,
  ) {
    return currentState.copyWith(
      submissionStatus: SmsScannerSubmissionStatus.failure,
      submissionErrorMessage: failureText(failure),
    );
  }
}
