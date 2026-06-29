import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/budget.dart';

/// Repository for managing budget data.
abstract class BudgetRepository {
  /// Retrieves all budgets.
  ///
  /// Returns [Right(List<Budget>)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, List<Budget>>> getBudgets();

  /// Retrieves a budget by its [id].
  ///
  /// Returns [Right(Budget)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, Budget>> getBudgetById(String id);

  /// Creates a new [budget].
  ///
  /// Returns [Right(Budget)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, Budget>> createBudget(Budget budget);

  /// Updates an existing [budget].
  ///
  /// Returns [Right(Budget)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, Budget>> updateBudget(Budget budget);

  /// Deletes a budget by [id].
  ///
  /// Returns [Right(unit)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, Unit>> deleteBudget(String id);

  /// Watches for changes to the budget list.
  Stream<List<Budget>> watchBudgets();
}
