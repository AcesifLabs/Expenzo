import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/utils/budget_period_utils.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import '../repositories/budget_repository.dart';

/// Fetches all records (transactions) for a given budget's current period.
class GetBudgetTransactions {
  final BudgetRepository budgetRepository;
  final RecordRepository recordRepository;

  GetBudgetTransactions({
    required this.budgetRepository,
    required this.recordRepository,
  });

  Future<Either<Failure, List<Record>>> call(String budgetId) async {
    final budgetResult = await budgetRepository.getBudgetById(budgetId);
    return budgetResult.fold((failure) => Left(failure), (budget) async {
      final periodRange = BudgetPeriodUtils.calculateCurrentPeriod(
        budget.startDate,
        budget.period,
      );

      final intCategoryId = int.tryParse(budget.categoryId ?? '');

      if (intCategoryId != null) {
        final result = await recordRepository.getRecordsByCategoryAndDateRange(
          intCategoryId,
          periodRange.start,
          periodRange.end,
        );
        return result.fold(
          (failure) => Left<Failure, List<Record>>(failure),
          (records) => Right<Failure, List<Record>>(records),
        );
      }

      // Overall budget: fetch all expense records in the period
      final result = await recordRepository.getRecordsByDateRangeOnly(
        periodRange.start,
        periodRange.end,
      );
      return result.fold(
        (failure) => Left<Failure, List<Record>>(failure),
        (records) => Right<Failure, List<Record>>(
          records.where((r) => r.recordType == RecordType.expense).toList(),
        ),
      );
    });
  }
}
