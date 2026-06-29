import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class UpdateBudget {
  final BudgetRepository repository;

  UpdateBudget({required this.repository});

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.

  Future<Either<Failure, Budget>> call(Budget budget) {
    return repository.updateBudget(budget);
  }
}
