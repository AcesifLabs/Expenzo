import 'package:equatable/equatable.dart';
import '../../../parsing_rules/domain/entities/parsed_transaction.dart';

abstract class SmsScannerState extends Equatable {
  const SmsScannerState();

  @override
  List<Object?> get props => [];
}

class SmsScannerInitial extends SmsScannerState {}

class SmsScannerScanning extends SmsScannerState {
  final int totalMessages;
  final int processedMessages;
  final DateTime? scanStartTime;

  const SmsScannerScanning({
    required this.totalMessages,
    required this.processedMessages,
    this.scanStartTime,
  });

  double get progress =>
      totalMessages > 0 ? processedMessages / totalMessages : 0;

  @override
  List<Object?> get props => [totalMessages, processedMessages, scanStartTime];
}

class SmsScannerScanComplete extends SmsScannerState {
  final List<ParsedTransaction> results;
  final DateTime lastScanTimestamp;
  final Set<String> selectedIds;
  final int currentOffset;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final DateTime? since;

  const SmsScannerScanComplete({
    required this.results,
    required this.lastScanTimestamp,
    this.selectedIds = const {},
    this.currentOffset = 0,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.since,
  });

  SmsScannerScanComplete copyWith({
    List<ParsedTransaction>? results,
    DateTime? lastScanTimestamp,
    Set<String>? selectedIds,
    int? currentOffset,
    bool? hasReachedMax,
    bool? isLoadingMore,
    DateTime? since,
  }) {
    return SmsScannerScanComplete(
      results: results ?? this.results,
      lastScanTimestamp: lastScanTimestamp ?? this.lastScanTimestamp,
      selectedIds: selectedIds ?? this.selectedIds,
      currentOffset: currentOffset ?? this.currentOffset,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      since: since ?? this.since,
    );
  }

  List<ParsedTransaction> get selectedTransactions =>
      results.where((r) => selectedIds.contains(r.sourceId)).toList();

  @override
  List<Object?> get props => [
    results,
    lastScanTimestamp,
    selectedIds,
    currentOffset,
    hasReachedMax,
    isLoadingMore,
    since,
  ];
}

class SmsScannerError extends SmsScannerState {
  final String message;

  const SmsScannerError({required this.message});

  @override
  List<Object?> get props => [message];
}
