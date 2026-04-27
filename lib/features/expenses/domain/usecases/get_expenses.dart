import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpenses extends UseCase<List<Expense>, GetExpensesParams> {
  final ExpenseRepository repository;

  GetExpenses(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(GetExpensesParams params) {
    return repository.getExpenses(
      dateRange: params.dateRange,
      categoryId: params.categoryId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetExpensesParams extends Params {
  final DateTimeRange? dateRange;
  final int? categoryId;
  final int? limit;
  final int? offset;

  const GetExpensesParams({
    this.dateRange,
    this.categoryId,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [dateRange, categoryId, limit, offset];
}
