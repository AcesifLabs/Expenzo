import 'package:equatable/equatable.dart';

/// The transaction dates an export covers: `[start, end)`.
class ExportPeriod extends Equatable {
  /// Null means from the first record.
  final DateTime? start;

  /// Exclusive. Null means up to the last record.
  final DateTime? end;

  @override
  List<Object?> get props => [start, end];

  const ExportPeriod({this.start, this.end});
}
