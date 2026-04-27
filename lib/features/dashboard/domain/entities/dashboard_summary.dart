import 'package:equatable/equatable.dart';
import '../../../records/domain/entities/record.dart';

class DashboardSummary extends Equatable {
  final double totalSpent;
  final double previousPeriodTotal;
  final double percentChange;
  final List<CategoryAmount> categoryBreakdown;
  final List<Record> recentTransactions;

  const DashboardSummary({
    required this.totalSpent,
    required this.previousPeriodTotal,
    required this.percentChange,
    required this.categoryBreakdown,
    required this.recentTransactions,
  });

  bool get isIncreased => percentChange > 0;
  bool get isDecreased => percentChange < 0;
  bool get hasNoChange => percentChange == 0;

  @override
  List<Object?> get props => [
    totalSpent,
    previousPeriodTotal,
    percentChange,
    categoryBreakdown,
    recentTransactions,
  ];
}

class CategoryAmount extends Equatable {
  final String categoryId;
  final String emoji;
  final String categoryName;
  final double amount;
  final double percentage;

  const CategoryAmount({
    required this.categoryId,
    required this.emoji,
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [
    categoryId,
    emoji,
    categoryName,
    amount,
    percentage,
  ];
}
