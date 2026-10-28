import 'package:equatable/equatable.dart';

import '../../domain/entities/export_request.dart';

sealed class ExportEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const ExportEvent();
}

class ExportRangeSelected extends ExportEvent {
  final ExportRange range;

  @override
  List<Object?> get props => [range];

  const ExportRangeSelected(this.range);
}

class ExportCustomRangePicked extends ExportEvent {
  final DateTime start;
  final DateTime end;

  @override
  List<Object?> get props => [start, end];

  const ExportCustomRangePicked(this.start, this.end);
}

class ExportContentToggled extends ExportEvent {
  final ExportContent content;
  final bool included;

  @override
  List<Object?> get props => [content, included];

  const ExportContentToggled(this.content, {required this.included});
}

class ExportRequested extends ExportEvent {
  const ExportRequested();
}
