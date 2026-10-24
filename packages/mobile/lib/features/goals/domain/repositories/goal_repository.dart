import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';

import '../entities/goal.dart';

abstract class GoalRepository {
  /// The goal the dashboard shows (the newest), or null.
  Future<Either<Failure, Goal?>> getActiveGoal();

  Stream<Goal?> watchActiveGoal();

  /// Left with [FailureCodes.notFound] when no goal has [id].
  Future<Either<Failure, Goal>> getGoalById(String id);

  Future<Either<Failure, Goal>> createGoal(Goal goal);

  Future<Either<Failure, Goal>> updateGoal(Goal goal);

  Future<Either<Failure, Unit>> deleteGoal(String id);
}
