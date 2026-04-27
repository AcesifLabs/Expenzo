import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/expense.dart';

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({required this.start, required this.end});
}

abstract class ExpenseRepository {
  Future<Either<CacheFailure, List<Expense>>> getExpenses({
    DateTimeRange? dateRange,
    int? categoryId,
    int? limit,
    int? offset,
  });
  Future<Either<CacheFailure, Expense>> getExpenseById(int id);
  Future<Either<CacheFailure, Expense>> addExpense(Expense expense);
  Future<Either<CacheFailure, Expense>> updateExpense(Expense expense);
  Future<Either<CacheFailure, Unit>> deleteExpense(int id);
  Stream<List<Expense>> watchExpenses({int? limit, int? offset});
  Future<Either<CacheFailure, bool>> expenseExistsBySourceId(String sourceId);
  Future<Either<CacheFailure, Set<String>>> getExistingSourceIds(
    List<String> sourceIds,
  );
  Future<Either<CacheFailure, void>> addExpensesBatch(List<Expense> expenses);
}
