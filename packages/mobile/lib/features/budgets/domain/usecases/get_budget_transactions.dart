import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/utils/budget_period_utils.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import '../repositories/budget_repository.dart';

/// Loads expense records in the current period for a named budget.
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

      final result = await recordRepository.getRecordsByDateRangeOnly(
        periodRange.start,
        periodRange.end,
      );

      return result.fold(
        (failure) => Left(failure),
        (records) => Right(
          records
              .where(
                (r) =>
                    r.recordType == RecordType.expense &&
                    r.budgetId == budgetId,
              )
              .toList(),
        ),
      );
    });
  }
}
