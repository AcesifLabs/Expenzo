import 'package:equatable/equatable.dart';
import '../../domain/entities/sms_scan_result_item.dart';

import '../helpers/scan_range_label_formatter.dart';
import '../helpers/sms_scan_result_presenter.dart';
import '../models/sender_result_section.dart';
import 'sms_scanner_submission_status.dart';
import 'sms_scanner_view_mode.dart';

sealed class SmsScannerState extends Equatable {
  @override
  List<Object?> get props => [];

  const SmsScannerState();
}

class SmsScannerInitial extends SmsScannerState {
  const SmsScannerInitial();
}

class SmsScannerScanning extends SmsScannerState {
  final int totalMessages;
  final int processedMessages;
  final DateTime? scanStartTime;

  double get progress =>
      totalMessages > 0 ? processedMessages / totalMessages : 0;

  @override
  List<Object?> get props => [totalMessages, processedMessages, scanStartTime];

  const SmsScannerScanning({
    required this.totalMessages,
    required this.processedMessages,
    this.scanStartTime,
  });
}

class SmsScannerScanComplete extends SmsScannerState {
  final List<SmsScanResultItem> results;
  final DateTime lastScanTimestamp;
  final Set<String> selectedIds;
  final int currentOffset;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final DateTime? startDate;
  final DateTime? endDate;
  final SmsScannerViewMode viewMode;
  final SmsScannerSubmissionStatus submissionStatus;
  final String? submissionErrorMessage;

  List<SmsScanResultItem> get selectedTransactions =>
      results.where((r) => selectedIds.contains(r.sourceId)).toList();

  Map<String, List<SmsScanResultItem>> get resultsBySender {
    final grouped = <String, List<SmsScanResultItem>>{};

    for (final result in results) {
      grouped.putIfAbsent(result.senderKey, () => []).add(result);
    }

    return grouped;
  }

  String get activeRangeLabel =>
      formatScanRangeLabel(startDate: startDate, endDate: endDate);

  List<SmsScanResultItem> get flatResults => sortResultsNewestFirst(results);

  List<SenderResultSection> get senderSections => buildSenderSections(results);

  @override
  List<Object?> get props => [
    results,
    lastScanTimestamp,
    selectedIds,
    currentOffset,
    hasReachedMax,
    isLoadingMore,
    startDate,
    endDate,
    viewMode,
    submissionStatus,
    submissionErrorMessage,
  ];

  const SmsScannerScanComplete({
    required this.results,
    required this.lastScanTimestamp,
    this.selectedIds = const {},
    this.currentOffset = 0,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.startDate,
    this.endDate,
    this.viewMode = SmsScannerViewMode.groupedBySender,
    this.submissionStatus = SmsScannerSubmissionStatus.idle,
    this.submissionErrorMessage,
  });

  int selectedCountForSender(String senderKey) {
    return resultsBySender[senderKey]
            ?.where((item) => selectedIds.contains(item.sourceId))
            .length ??
        0;
  }

  Set<String> sourceIdsForSender(String senderKey) {
    return resultsBySender[senderKey]?.map((item) => item.sourceId).toSet() ??
        <String>{};
  }

  SmsScannerScanComplete copyWith({
    List<SmsScanResultItem>? results,
    DateTime? lastScanTimestamp,
    Set<String>? selectedIds,
    int? currentOffset,
    bool? hasReachedMax,
    bool? isLoadingMore,
    DateTime? startDate,
    DateTime? endDate,
    SmsScannerViewMode? viewMode,
    SmsScannerSubmissionStatus? submissionStatus,
    String? submissionErrorMessage,
    bool clearSubmissionErrorMessage = false,
  }) {
    return SmsScannerScanComplete(
      results: results ?? this.results,
      lastScanTimestamp: lastScanTimestamp ?? this.lastScanTimestamp,
      selectedIds: selectedIds ?? this.selectedIds,
      currentOffset: currentOffset ?? this.currentOffset,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      viewMode: viewMode ?? this.viewMode,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      submissionErrorMessage: clearSubmissionErrorMessage
          ? null
          : submissionErrorMessage ?? this.submissionErrorMessage,
    );
  }
}

class SmsScannerError extends SmsScannerState {
  final String message;

  @override
  List<Object?> get props => [message];

  const SmsScannerError({required this.message});
}
