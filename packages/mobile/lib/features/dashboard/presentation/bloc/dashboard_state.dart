import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/date_range.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];

  const DashboardState();
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {
  final DateRange dateRange;

  @override
  List<Object?> get props => [dateRange];

  const DashboardLoading({required this.dateRange});
}

class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;
  final DateRange dateRange;

  @override
  List<Object?> get props => [summary, dateRange];

  const DashboardLoaded({required this.summary, required this.dateRange});
}

class DashboardError extends DashboardState {
  final String message;

  @override
  List<Object?> get props => [message];

  const DashboardError({required this.message});
}
