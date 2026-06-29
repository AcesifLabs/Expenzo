import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../../../records/domain/entities/record.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/date_range.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final RecordRepository _recordRepository;
  final CategoryRepository _categoryRepository;

  DashboardRepositoryImpl({
    required RecordRepository recordRepository,
    required CategoryRepository categoryRepository,
  }) : _recordRepository = recordRepository,
       _categoryRepository = categoryRepository;

  /// Returns Left(Failure) on error.
  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary(
    DateRange dateRange,
  ) async {
    try {
      final currentRecords = await _fetchRecords(dateRange);
      final previousRecords = await _fetchRecords(dateRange.previousPeriod);

      final totalIncome = _calculateByType(currentRecords, RecordType.income);
      final totalExpense = _calculateByType(currentRecords, RecordType.expense);
      final totalSpent = totalIncome + totalExpense;
      final previousPeriodTotal = _calculateTotal(previousRecords);

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
      print('Error: $e\n$s');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<List<Record>> _fetchRecords(DateRange dateRange) async {
    final result = await _recordRepository.getRecords(
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
    final totalSpent = _calculateTotal(records);

    if (totalSpent == 0) return [];

    final categoryMap = <String, double>{};
    for (final record in records) {
      final catId = record.categoryId;
      if (catId != null) {
        categoryMap[catId] = (categoryMap[catId] ?? 0) + record.amount.abs();
      }
    }

    final categoryResult = await _categoryRepository.getCategories();

    return categoryResult.fold((failure) => [], (categories) {
      final breakdown = <CategoryAmount>[];
      for (final entry in categoryMap.entries) {
        final category = categories.firstWhere(
          (c) => c.id == entry.key,
          orElse: () => throw ArgumentError('Category not found: ${entry.key}'),
        );
        final amount = entry.value;
        breakdown.add(
          CategoryAmount(
            categoryId: category.id ?? '',
            emoji: category.emoji,
            categoryName: category.name,
            amount: amount,
            percentage: (amount / totalSpent) * 100,
          ),
        );
      }

      breakdown.sort((a, b) => b.amount.compareTo(a.amount));

      return breakdown;
    });
  }
}
