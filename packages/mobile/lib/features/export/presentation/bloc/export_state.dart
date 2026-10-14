import 'package:equatable/equatable.dart';

import '../../domain/entities/export_request.dart';

enum ExportStatus { idle, exporting, shared, empty, failed }

/// The screen's choices and where the last export got to.
class ExportState extends Equatable {
  final ExportRange range;
  final DateTime? customStart;
  final DateTime? customEnd;
  final Set<ExportContent> contents;
  final ExportStatus status;

  /// Set for [ExportStatus.empty] and [ExportStatus.failed].
  final String? errorMessage;

  @override
  List<Object?> get props => [
    range,
    customStart,
    customEnd,
    contents,
    status,
    errorMessage,
  ];

  ExportRequest get request => ExportRequest(
    range: range,
    customStart: customStart,
    customEnd: customEnd,
    contents: contents,
  );

  bool get isExporting => status == ExportStatus.exporting;

  /// Choices are fixed while an export runs, so its result matches them.
  bool get canExport => request.isValid && !isExporting;

  const ExportState({
    this.range = ExportRange.allTime,
    this.customStart,
    this.customEnd,
    this.contents = const {
      ExportContent.transactions,
      ExportContent.budgets,
      ExportContent.categories,
    },
    this.status = ExportStatus.idle,
    this.errorMessage,
  });

  /// [errorMessage] is replaced, not kept: leaving it out clears it.
  ExportState copyWith({
    ExportRange? range,
    DateTime? customStart,
    DateTime? customEnd,
    Set<ExportContent>? contents,
    ExportStatus? status,
    String? errorMessage,
  }) {
    return ExportState(
      range: range ?? this.range,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
      contents: contents ?? this.contents,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}
