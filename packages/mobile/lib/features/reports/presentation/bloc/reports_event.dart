import 'package:equatable/equatable.dart';
import '../../domain/repositories/reports_repository.dart';

abstract class ReportsEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const ReportsEvent();
}

class LoadReports extends ReportsEvent {
  final DateTime startDate;
  final DateTime endDate;
  final Granularity granularity;

  @override
  List<Object?> get props => [startDate, endDate, granularity];

  const LoadReports({
    required this.startDate,
    required this.endDate,
    required this.granularity,
  });
}

class ChangeDateRange extends ReportsEvent {
  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object?> get props => [startDate, endDate];

  const ChangeDateRange({required this.startDate, required this.endDate});
}

class ChangeGranularity extends ReportsEvent {
  final Granularity granularity;

  @override
  List<Object?> get props => [granularity];

  const ChangeGranularity({required this.granularity});
}
