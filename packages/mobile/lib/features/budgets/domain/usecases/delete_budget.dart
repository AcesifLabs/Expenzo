import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../repositories/budget_repository.dart';

class DeleteBudget {
  final BudgetRepository repository;

  DeleteBudget({required this.repository});

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.

  Future<Either<Failure, Unit>> call(String id) {
    return repository.deleteBudget(id);
  }
}
