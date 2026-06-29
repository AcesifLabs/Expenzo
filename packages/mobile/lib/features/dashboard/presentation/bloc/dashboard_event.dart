import 'package:equatable/equatable.dart';
import '../../domain/entities/date_range.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const DashboardEvent();
}

class LoadDashboard extends DashboardEvent {
  final DateRange dateRange;

  @override
  List<Object?> get props => [dateRange];

  const LoadDashboard({required this.dateRange});
}

class ChangeDateRange extends DashboardEvent {
  final DateRangePreset preset;

  @override
  List<Object?> get props => [preset];

  const ChangeDateRange({required this.preset});
}

class RefreshDashboard extends DashboardEvent {}
