import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/date_range.dart';

class GetDashboardSummaryUseCase
    implements UseCase<DashboardSummary, DateRange> {
  final ExpenseRepository expenseRepository;
  final CategoryRepository categoryRepository;

  GetDashboardSummaryUseCase({
    required this.expenseRepository,
    required this.categoryRepository,
  });

  @override
  Future<Either<Failure, DashboardSummary>> call(DateRange dateRange) async {
    try {
      // Get current period expenses
      final currentResult = await expenseRepository.getExpenses(
        dateRange: DateTimeRange(
          start: dateRange.startDate,
          end: dateRange.endDate,
        ),
      );

      final List<Expense> currentExpenses = currentResult.fold(
        (failure) => [],
        (expenses) => expenses,
      );

      // Get previous period expenses
      final previousDateRange = dateRange.previousPeriod;
      final previousResult = await expenseRepository.getExpenses(
        dateRange: DateTimeRange(
          start: previousDateRange.startDate,
          end: previousDateRange.endDate,
        ),
      );

      final List<Expense> previousExpenses = previousResult.fold(
        (failure) => [],
        (expenses) => expenses,
      );

      // Calculate totals
      final totalSpent = _calculateTotal(currentExpenses);
      final previousPeriodTotal = _calculateTotal(previousExpenses);

      // Calculate percent change
      double percentChange = 0;
      if (previousPeriodTotal > 0) {
        percentChange =
            ((totalSpent - previousPeriodTotal) / previousPeriodTotal) * 100;
      }

      // Calculate category breakdown
      final categoryBreakdown = await _calculateCategoryBreakdown(
        currentExpenses,
      );

      // Get recent transactions (last 5)
      final sortedExpenses = List<Expense>.from(currentExpenses)
        ..sort((a, b) => b.date.compareTo(a.date));
      final recentTransactions = sortedExpenses.take(5).toList();

      return Right(
        DashboardSummary(
          totalSpent: totalSpent,
          previousPeriodTotal: previousPeriodTotal,
          percentChange: percentChange,
          categoryBreakdown: categoryBreakdown,
          recentTransactions: recentTransactions,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  double _calculateTotal(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount.abs());
  }

  Future<List<CategoryAmount>> _calculateCategoryBreakdown(
    List<Expense> expenses,
  ) async {
    final totalSpent = _calculateTotal(expenses);
    if (totalSpent == 0) return [];

    final categoryMap = <int, double>{};
    for (final expense in expenses) {
      if (expense.categoryId != null) {
        categoryMap[expense.categoryId!] =
            (categoryMap[expense.categoryId!] ?? 0) + expense.amount.abs();
      }
    }

    final categoryResult = await categoryRepository.getCategories();

    return categoryResult.fold((failure) => [], (categories) {
      final breakdown = <CategoryAmount>[];
      for (final entry in categoryMap.entries) {
        final category = categories.firstWhere(
          (c) => c.id == entry.key,
          orElse: () => throw Exception('Category not found'),
        );
        final amount = entry.value;
        breakdown.add(
          CategoryAmount(
            categoryId: category.id.toString(),
            emoji: category.emoji,
            categoryName: category.name,
            amount: amount,
            percentage: (amount / totalSpent) * 100,
          ),
        );
      }
      // Sort by amount descending
      breakdown.sort((a, b) => b.amount.compareTo(a.amount));
      return breakdown;
    });
  }
}
