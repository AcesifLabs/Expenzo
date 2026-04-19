import 'package:equatable/equatable.dart';
import '../../domain/entities/date_amount.dart';
import '../../domain/entities/category_amount.dart';
import '../../domain/entities/spending_insights.dart';
import '../../domain/repositories/reports_repository.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<DateAmount> spendingTrend;
  final List<CategoryAmount> categoryBreakdown;
  final SpendingInsights insights;
  final DateTime startDate;
  final DateTime endDate;
  final Granularity granularity;

  const ReportsLoaded({
    required this.spendingTrend,
    required this.categoryBreakdown,
    required this.insights,
    required this.startDate,
    required this.endDate,
    required this.granularity,
  });

  @override
  List<Object?> get props => [
    spendingTrend,
    categoryBreakdown,
    insights,
    startDate,
    endDate,
    granularity,
  ];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError({required this.message});

  @override
  List<Object?> get props => [message];
}
