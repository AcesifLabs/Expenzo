import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/date_range.dart';

sealed class DashboardState extends Equatable {
  final DateRange? dateRange;

  @override
  List<Object?> get props => [dateRange];

  const DashboardState({this.dateRange});
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading({super.dateRange});
}

class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;

  @override
  List<Object?> get props => [summary];

  const DashboardLoaded({required this.summary, required super.dateRange});
}

class DashboardError extends DashboardState {
  final String message;

  @override
  List<Object?> get props => [message];

  const DashboardError({required this.message});
}
