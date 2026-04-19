import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
import '../repositories/expense_repository.dart';

class DeleteExpense extends UseCase<Unit, int> {
  final ExpenseRepository repository;

  DeleteExpense(this.repository);

  @override
  Future<Either<Failure, Unit>> call(int id) {
    return repository.deleteExpense(id);
  }
}
