import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import '../../../records/domain/repositories/record_repository.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/date_range.dart';

class GetDashboardSummary implements UseCase<DashboardSummary, DateRange> {
  final RecordRepository recordRepository;
  final CategoryRepository categoryRepository;

  GetDashboardSummary({
    required this.recordRepository,
    required this.categoryRepository,
  });

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, DashboardSummary>> call(DateRange dateRange) async {
    try {
      final currentRecords = await _fetchRecords(dateRange);
      final previousRecords = await _fetchRecords(dateRange.previousPeriod);

      final totalIncome = _calculateByType(currentRecords, RecordType.income);
      final totalExpense = _calculateByType(currentRecords, RecordType.expense);
      // "Spent" is expense-only — income is tracked separately
      final totalSpent = totalExpense;
      final previousPeriodTotal = _calculateByType(
        previousRecords,
        RecordType.expense,
      );

      double percentChange = 0;
      if (previousPeriodTotal > 0) {
        percentChange =
            ((totalSpent - previousPeriodTotal) / previousPeriodTotal) * 100;
      }

      final categoryBreakdown = await _calculateCategoryBreakdown(
        currentRecords,
      );

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
    } catch (e, s) {
      appLogger.error('Error getting dashboard summary', e, s);

      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<List<Record>> _fetchRecords(DateRange dateRange) async {
    final result = await recordRepository.getRecords(
      dateRange: DateTimeRange(
        start: dateRange.startDate,
        end: dateRange.endDate,
      ),
    );

    return result.fold((failure) => [], (records) => records);
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
    // Only include expenses in the category breakdown
    final expenseRecords = records
        .where((r) => r.recordType == RecordType.expense)
        .toList();
    final totalExpense = _calculateTotal(expenseRecords);

    if (totalExpense == 0) return [];

    final categoryMap = <String, double>{};
    for (final record in expenseRecords) {
      final catId = record.categoryId;
      if (catId != null) {
        categoryMap[catId] = (categoryMap[catId] ?? 0) + record.amount.abs();
      }
    }

    final categoryResult = await categoryRepository.getCategories();

    return categoryResult.fold((failure) => [], (categories) {
      final breakdown = <CategoryAmount>[];
      for (final entry in categoryMap.entries) {
        // Skip orphaned categories instead of throwing
        final matching = categories.where((c) => c.id == entry.key);
        if (matching.isEmpty) {
          // Bucket as "Uncategorized"
          breakdown.add(
            CategoryAmount(
              categoryId: entry.key,
              emoji: '❓',
              categoryName: 'Uncategorized',
              amount: entry.value,
              percentage: (entry.value / totalExpense) * 100,
            ),
          );
          continue;
        }
        final category = matching.first;
        final amount = entry.value;
        breakdown.add(
          CategoryAmount(
            categoryId: category.id ?? '',
            emoji: category.emoji,
            categoryName: category.name,
            amount: amount,
            percentage: (amount / totalExpense) * 100,
          ),
        );
      }

      breakdown.sort((a, b) => b.amount.compareTo(a.amount));

      return breakdown;
    });
  }
}
