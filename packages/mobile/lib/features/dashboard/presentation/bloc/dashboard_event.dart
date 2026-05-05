import 'package:equatable/equatable.dart';
import '../../domain/entities/date_range.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  final DateRange dateRange;

  const LoadDashboard({required this.dateRange});

  @override
  List<Object?> get props => [dateRange];
}

class ChangeDateRange extends DashboardEvent {
  final DateRangePreset preset;

  const ChangeDateRange({required this.preset});

  @override
  List<Object?> get props => [preset];
}

class RefreshDashboard extends DashboardEvent {}
