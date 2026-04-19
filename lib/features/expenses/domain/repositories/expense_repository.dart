import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
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
  Stream<List<Expense>> watchExpenses();
  Future<Either<CacheFailure, bool>> expenseExistsBySourceId(String sourceId);
}
