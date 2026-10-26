import 'package:equatable/equatable.dart';

class ExportPeriod extends Equatable {
  final DateTime? start;

  final DateTime? end;

  @override
  List<Object?> get props => [start, end];

  const ExportPeriod({this.start, this.end});
}
