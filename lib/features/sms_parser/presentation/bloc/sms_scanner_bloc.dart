import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsed_transaction.dart';
import 'package:expense_tracker/features/parsing_rules/domain/services/parsing_isolate_service.dart';
import 'package:expense_tracker/features/parsing_rules/domain/usecases/evaluate_rules.dart';
import 'package:expense_tracker/features/sms_parser/data/datasources/sms_local_datasource.dart';
import 'package:expense_tracker/features/sms_parser/domain/entities/sms_message.dart';
import '../../domain/usecases/scan_sms_usecase.dart';
import 'sms_scanner_event.dart';
import 'sms_scanner_state.dart';

const _scanPageSize = 10;

class SmsScannerBloc extends Bloc<SmsScannerEvent, SmsScannerState> {
  final ScanSmsUseCase scanSmsUseCase;
  final ExpenseRepository expenseRepository;

  SmsScannerBloc({
    required this.scanSmsUseCase,
    required this.expenseRepository,
  }) : super(SmsScannerInitial()) {
    on<StartScan>(_onStartScan);
    on<LoadMoreScanResults>(_onLoadMore);
    on<ToggleSelection>(_onToggleSelection);
    on<SelectAll>(_onSelectAll);
    on<DeselectAll>(_onDeselectAll);
    on<ClearResults>(_onClearResults);
  }

  Future<void> _onStartScan(
    StartScan event,
    Emitter<SmsScannerState> emit,
  ) async {
    emit(const SmsScannerScanning(processedMessages: 0, totalMessages: 0));

    // 1. Fetch all monitored sources (MessageSources)
    final context = await di.getIt<EvaluateRulesUseCase>().loadContext();
    final monitoredSources = context.sources.where((s) => s.isMonitored).toList();

    List<ParsedTransaction> allResults = [];
    
    // 2. Iterate through each monitored source and fetch its messages
    for (final source in monitoredSources) {
      final messages = await di.getIt<SmsLocalDatasource>().getSmsFromAddress(source.contactId);
      
      // Filter by date if provided
      List<SmsMessage> filteredMessages = messages;
      if (event.since != null) {
        filteredMessages = messages
            .where((m) => m.date.isAfter(event.since!))
            .toList();
      }

      if (filteredMessages.isEmpty) continue;

      // Prepare input for isolate
      final parseInputs = filteredMessages.map((message) {
        return ParseMessageInput(
          body: message.body,
          address: message.address,
          date: message.date,
          sourceId: '${message.address}_${message.date.toIso8601String()}'.hashCode.abs().toString(),
        );
      }).toList();

      // Parse messages
      final results = await di.getIt<ParsingIsolateService>().parseMessages(
        messages: parseInputs,
        context: context,
        sourceType: 'sms',
      );
      
      allResults.addAll(results);
    }

    // 3. Filter duplicates against existing DB records
    final finalResults = await _filterDuplicates(
      allResults,
      event.filterDuplicates,
    );

    emit(
      SmsScannerScanComplete(
        results: finalResults,
        selectedIds: finalResults.map((t) => t.sourceId).toSet(),
        lastScanTimestamp: DateTime.now(),
        // For per-sender scan, pagination logic is different. Setting hasReachedMax to true.
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

    // Iteratively fetch batches until we find new valid results or reach the end.
    List<ParsedTransaction> newFiltered = [];
    int offset = currentState.currentOffset;
    bool hasReachedMax = false;

    while (newFiltered.isEmpty && !hasReachedMax) {
      final result = await scanSmsUseCase(
        ScanSmsParams(since: currentState.since, offset: offset, limit: _scanPageSize),
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

  /// Filters out transactions whose sourceId already exists in the DB.
  Future<List<ParsedTransaction>> _filterDuplicates(
    List<ParsedTransaction> transactions,
    bool filterDuplicates,
  ) async {
    if (!filterDuplicates || transactions.isEmpty) return transactions;

    final sourceIds = transactions.map((t) => t.sourceId).toList();
    final existingIdsResult = await expenseRepository.getExistingSourceIds(
      sourceIds,
    );
    final existingIds = existingIdsResult.getOrElse(() => <String>{});

    return transactions
        .where((t) => !existingIds.contains(t.sourceId))
        .toList();
  }

  void _onClearResults(ClearResults event, Emitter<SmsScannerState> emit) {
    emit(SmsScannerInitial());
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
}
