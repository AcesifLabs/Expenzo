import 'package:equatable/equatable.dart';
import '../../domain/repositories/reports_repository.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadReports extends ReportsEvent {
  final DateTime startDate;
  final DateTime endDate;
  final Granularity granularity;

  const LoadReports({
    required this.startDate,
    required this.endDate,
    required this.granularity,
  });

  @override
  List<Object?> get props => [startDate, endDate, granularity];
}

class ChangeDateRange extends ReportsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const ChangeDateRange({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class ChangeGranularity extends ReportsEvent {
  final Granularity granularity;

  const ChangeGranularity({required this.granularity});

  @override
  List<Object?> get props => [granularity];
}
