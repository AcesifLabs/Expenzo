import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/date_range.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {
  final DateRange dateRange;

  const DashboardLoading({required this.dateRange});

  @override
  List<Object?> get props => [dateRange];
}

class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;
  final DateRange dateRange;

  const DashboardLoaded({required this.summary, required this.dateRange});

  @override
  List<Object?> get props => [summary, dateRange];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
