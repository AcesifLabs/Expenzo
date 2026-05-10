import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../../../records/domain/entities/record.dart';
import '../../../records/domain/repositories/record_repository.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/date_range.dart';

class GetDashboardSummaryUseCase
    implements UseCase<DashboardSummary, DateRange> {
  final RecordRepository recordRepository;
  final CategoryRepository categoryRepository;

  GetDashboardSummaryUseCase({
    required this.recordRepository,
    required this.categoryRepository,
  });

  @override
  Future<Either<Failure, DashboardSummary>> call(DateRange dateRange) async {
    try {
      // Get current period records
      final currentResult = await recordRepository.getRecords(
        dateRange: DateTimeRange(
          start: dateRange.startDate,
          end: dateRange.endDate,
        ),
      );

      final List<Record> currentRecords = currentResult.fold(
        (failure) => [],
        (records) => records,
      );

      // Get previous period records
      final previousDateRange = dateRange.previousPeriod;
      final previousResult = await recordRepository.getRecords(
        dateRange: DateTimeRange(
          start: previousDateRange.startDate,
          end: previousDateRange.endDate,
        ),
      );

      final List<Record> previousRecords = previousResult.fold(
        (failure) => [],
        (records) => records,
      );

      // Calculate income, expense & totals
      final totalIncome = _calculateByType(currentRecords, RecordType.income);
      final totalExpense = _calculateByType(currentRecords, RecordType.expense);
      final totalSpent = totalIncome + totalExpense;
      final previousPeriodTotal = _calculateTotal(previousRecords);

      // Calculate percent change
      double percentChange = 0;
      if (previousPeriodTotal > 0) {
        percentChange =
            ((totalSpent - previousPeriodTotal) / previousPeriodTotal) * 100;
      }

      // Calculate category breakdown
      final categoryBreakdown = await _calculateCategoryBreakdown(
        currentRecords,
      );

      // Get recent transactions (last 5)
      final sortedRecords = List<Record>.from(currentRecords)
        ..sort((a, b) => b.date.compareTo(a.date));
      final recentTransactions = sortedRecords.take(5).toList();

      return Right(
        DashboardSummary(
          totalIncome: totalIncome,
          totalExpense: totalExpense,
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

  double _calculateTotal(List<Record> records) {
    return records.fold(0.0, (sum, record) => sum + record.amount.abs());
  }

  double _calculateByType(List<Record> records, RecordType type) {
    return records
        .where((r) => r.recordType == type)
        .fold(0.0, (sum, r) => sum + r.amount.abs());
  }

  Future<List<CategoryAmount>> _calculateCategoryBreakdown(
    List<Record> records,
  ) async {
    final totalSpent = _calculateTotal(records);
    if (totalSpent == 0) return [];

    final categoryMap = <String, double>{};
    for (final record in records) {
      if (record.categoryId != null) {
        categoryMap[record.categoryId!] =
            (categoryMap[record.categoryId!] ?? 0) + record.amount.abs();
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
            categoryId: category.id!,
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
