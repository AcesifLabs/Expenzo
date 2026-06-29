import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsed_transaction.dart';
import 'package:expense_tracker/features/parsing_rules/domain/services/parsing_isolate_service.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_context.dart';
import 'package:expense_tracker/features/parsing_rules/domain/usecases/evaluate_rules_use_case.dart';
import 'package:expense_tracker/features/sms_parser/data/datasources/sms_local_datasource.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_event.dart';
import '../../domain/usecases/scan_sms_usecase.dart';
import 'package:expense_tracker/features/records/domain/usecases/create_records_from_parsed_list.dart';
import 'sms_scanner_event.dart';
import 'sms_scanner_state.dart';

const _scanPageSize = 10;

class SmsScannerBloc extends Bloc<SmsScannerEvent, SmsScannerState> {
  final ScanSmsUseCase scanSmsUseCase;
  final RecordRepository recordRepository;
  final CreateRecordsFromParsedList createRecordsFromParsedList;

  SmsScannerBloc({
    required this.scanSmsUseCase,
    required this.recordRepository,
    required this.createRecordsFromParsedList,
  }) : super(SmsScannerInitial()) {
    on<StartScan>(_onStartScan);
    on<LoadMoreScanResults>(_onLoadMore);
    on<ToggleSelection>(_onToggleSelection);
    on<SelectAll>(_onSelectAll);
    on<DeselectAll>(_onDeselectAll);
    on<ClearResults>(_onClearResults);
    on<CreateSelectedExpenses>(_onCreateSelectedExpenses);
  }

  Future<void> _onStartScan(
    StartScan event,
    Emitter<SmsScannerState> emit,
  ) async {
    emit(const SmsScannerScanning(processedMessages: 0, totalMessages: 0));

    final context = await di.getIt<EvaluateRulesUseCase>().loadContext();
    final hasMonitoredSources = context.sources.any((s) => s.isMonitored);
    if (!hasMonitoredSources) {
      _emitEmptyResults(emit, event);

      return;
    }

    final results = await _scanAndParse(context, event);
    if (results.isEmpty) {
      _emitEmptyResults(emit, event);

      return;
    }

    final finalResults = await _filterDuplicates(
      results,
      event.filterDuplicates,
    );

    emit(
      SmsScannerScanComplete(
        results: finalResults,
        selectedIds: finalResults.map((t) => t.sourceId).toSet(),
        lastScanTimestamp: DateTime.now(),
        hasReachedMax: true,
        since: event.since,
      ),
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

    List<ParsedTransaction> newFiltered = [];
    int offset = currentState.currentOffset;
    bool hasReachedMax = false;

    while (newFiltered.isEmpty && !hasReachedMax) {
      final result = await scanSmsUseCase(
        ScanSmsParams(
          since: currentState.since,
          offset: offset,
          limit: _scanPageSize,
        ),
      );

      final transactions = result.getOrElse(() => []);
      if (transactions.isEmpty) {
        hasReachedMax = true;
      } else {
        final filtered = await _filterDuplicates(
          transactions,
          event.filterDuplicates,
        );
        newFiltered.addAll(filtered);
        offset += _scanPageSize;
        if (transactions.length < _scanPageSize) {
          hasReachedMax = true;
        }
      }
    }

    final allResults = [...currentState.results, ...newFiltered];

    emit(
      currentState.copyWith(
        results: allResults,
        selectedIds: {...currentState.selectedIds}
          ..addAll(newFiltered.map((t) => t.sourceId)),
        currentOffset: offset,
        hasReachedMax: hasReachedMax,
        isLoadingMore: false,
      ),
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
      emit(currentState.copyWith(selectedIds: newSelectedIds));
    }
  }

  void _onSelectAll(SelectAll event, Emitter<SmsScannerState> emit) {
    final currentState = state;
    if (currentState is SmsScannerScanComplete) {
      final allIds = currentState.results.map((r) => r.sourceId).toSet();
      emit(currentState.copyWith(selectedIds: allIds));
    }
  }

  void _onDeselectAll(DeselectAll event, Emitter<SmsScannerState> emit) {
    final currentState = state;
    if (currentState is SmsScannerScanComplete) {
      emit(currentState.copyWith(selectedIds: {}));
    }
  }

  void _onClearResults(ClearResults event, Emitter<SmsScannerState> emit) {
    emit(SmsScannerInitial());
  }

  Future<void> _onCreateSelectedExpenses(
    CreateSelectedExpenses event,
    Emitter<SmsScannerState> emit,
  ) async {
    final result = await createRecordsFromParsedList(event.transactions);

    result.fold((failure) => emit(SmsScannerError(message: failure.message)), (
      creationResult,
    ) {
      try {
        di.getIt<BudgetBloc>().add(LoadBudgets());
      } catch (e) {
        debugPrint('SmsScannerBloc: Failed to reload budgets: $e');
      }
      add(ClearResults());
    });
  }

  void _emitEmptyResults(Emitter<SmsScannerState> emit, StartScan event) {
    emit(
      SmsScannerScanComplete(
        results: const [],
        selectedIds: const {},
        lastScanTimestamp: DateTime.now(),
        hasReachedMax: true,
        since: event.since,
      ),
    );
  }

  Future<List<ParsedTransaction>> _scanAndParse(
    ParsingContext context,
    StartScan event,
  ) async {
    final monitoredSources = context.sources
        .where((s) => s.isMonitored)
        .toList();

    final monitoredAddresses = monitoredSources.map((s) => s.contactId).toSet();

    final allRecentMessages = await di
        .getIt<SmsLocalDatasource>()
        .getSmsBatched(count: 200);

    final filteredMessages = allRecentMessages.where((m) {
      final isMonitored = monitoredAddresses.contains(m.address);
      final since = event.since;
      final isRecent = since == null || m.date.isAfter(since);

      return isMonitored && isRecent;
    }).toList();

    if (filteredMessages.isEmpty) return [];

    final parseInputs = filteredMessages.map((message) {
      return ParseMessageInput(
        body: message.body,
        address: message.address,
        date: message.date,
        sourceId: '${message.address}_${message.date.toIso8601String()}'
            .hashCode
            .abs()
            .toString(),
      );
    }).toList();

    return di.getIt<ParsingIsolateService>().parseMessages(
      messages: parseInputs,
      context: context,
      sourceType: AppSourceType.sms,
    );
  }

  Future<List<ParsedTransaction>> _filterDuplicates(
    List<ParsedTransaction> transactions,
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
}
