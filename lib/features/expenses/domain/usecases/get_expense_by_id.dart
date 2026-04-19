import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpenseById extends UseCase<Expense, int> {
  final ExpenseRepository repository;

  GetExpenseById(this.repository);

  @override
  Future<Either<Failure, Expense>> call(int id) {
    return repository.getExpenseById(id);
  }
}
