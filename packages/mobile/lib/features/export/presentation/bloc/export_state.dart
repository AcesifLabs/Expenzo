import 'package:equatable/equatable.dart';

import '../../domain/entities/export_request.dart';

enum ExportStatus { idle, exporting, shared, empty, failed }

class ExportState extends Equatable {
  final ExportRange range;
  final DateTime? customStart;
  final DateTime? customEnd;
  final Set<ExportContent> contents;
  final ExportStatus status;

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
