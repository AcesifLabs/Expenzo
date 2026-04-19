import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class AddExpense extends UseCase<Expense, Expense> {
  final ExpenseRepository repository;

  AddExpense(this.repository);

  @override
  Future<Either<Failure, Expense>> call(Expense expense) {
    return repository.addExpense(expense);
  }
}
