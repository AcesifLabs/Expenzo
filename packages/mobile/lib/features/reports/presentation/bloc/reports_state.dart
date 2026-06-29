import 'package:equatable/equatable.dart';
import '../../domain/entities/date_amount.dart';
import '../../domain/entities/category_amount.dart';
import '../../domain/entities/spending_insights.dart';
import '../../domain/entities/granularity.dart';

sealed class ReportsState extends Equatable {
  @override
  List<Object?> get props => [];

  const ReportsState();
}

class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

class ReportsLoaded extends ReportsState {
  final List<DateAmount> spendingTrend;
  final List<CategoryAmount> categoryBreakdown;
  final SpendingInsights insights;
  final DateTime startDate;
  final DateTime endDate;
  final Granularity granularity;

  @override
  List<Object?> get props => [
    spendingTrend,
    categoryBreakdown,
    insights,
    startDate,
    endDate,
    granularity,
  ];

  const ReportsLoaded({
    required this.spendingTrend,
    required this.categoryBreakdown,
    required this.insights,
    required this.startDate,
    required this.endDate,
    required this.granularity,
  });
}

class ReportsError extends ReportsState {
  final String message;

  @override
  List<Object?> get props => [message];

  const ReportsError({required this.message});
}
