import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/budget.dart';
import '../entities/plan_changes.dart';

abstract class BudgetRepository {
  Future<Either<Failure, List<Budget>>> getBudgets();

  Future<Either<Failure, Budget>> getBudgetById(String id);

  Future<Either<Failure, Budget>> createBudget(Budget budget);

  Future<Either<Failure, Budget>> updateBudget(Budget budget);

  Future<Either<Failure, Unit>> deleteBudget(String id);

  Stream<List<Budget>> watchBudgets();

  /// Applies a Budget Plan save all at once: nothing is written if any
  /// part fails, and sync runs once for the whole save.
  Future<Either<Failure, Unit>> applyPlanChanges(PlanChanges changes);
}
