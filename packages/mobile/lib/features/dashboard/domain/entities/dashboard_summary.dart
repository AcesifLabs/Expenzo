import 'package:equatable/equatable.dart';
import '../../../records/domain/entities/record.dart';

class DashboardSummary extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double totalSpent;
  final double previousPeriodTotal;
  final double percentChange;
  final List<CategoryAmount> categoryBreakdown;
  final List<Record> recentTransactions;

  double get totalBalance => totalIncome - totalExpense;

  bool get isIncreased => percentChange > 0;
  bool get isDecreased => percentChange < 0;
  bool get hasNoChange => percentChange == 0;

  @override
  List<Object?> get props => [
    totalIncome,
    totalExpense,
    totalSpent,
    previousPeriodTotal,
    percentChange,
    categoryBreakdown,
    recentTransactions,
  ];

  const DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSpent,
    required this.previousPeriodTotal,
    required this.percentChange,
    required this.categoryBreakdown,
    required this.recentTransactions,
  });

  DashboardSummary copyWith({
    double? totalIncome,
    double? totalExpense,
    double? totalSpent,
    double? previousPeriodTotal,
    double? percentChange,
    List<CategoryAmount>? categoryBreakdown,
    List<Record>? recentTransactions,
  }) {
    return DashboardSummary(
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      totalSpent: totalSpent ?? this.totalSpent,
      previousPeriodTotal: previousPeriodTotal ?? this.previousPeriodTotal,
      percentChange: percentChange ?? this.percentChange,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      recentTransactions: recentTransactions ?? this.recentTransactions,
    );
  }
}

class CategoryAmount extends Equatable {
  final String categoryId;
  final String emoji;
  final String categoryName;
  final double amount;
  final double percentage;

  @override
  List<Object?> get props => [
    categoryId,
    emoji,
    categoryName,
    amount,
    percentage,
  ];

  const CategoryAmount({
    required this.categoryId,
    required this.emoji,
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });

  CategoryAmount copyWith({
    String? categoryId,
    String? emoji,
    String? categoryName,
    double? amount,
    double? percentage,
  }) {
    return CategoryAmount(
      categoryId: categoryId ?? this.categoryId,
      emoji: emoji ?? this.emoji,
      categoryName: categoryName ?? this.categoryName,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
    );
  }
}
