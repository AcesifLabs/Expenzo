import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class GetBudgets {
  final BudgetRepository repository;

  GetBudgets({required this.repository});

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.

  Future<Either<Failure, List<Budget>>> call() {
    return repository.getBudgets();
  }
}
