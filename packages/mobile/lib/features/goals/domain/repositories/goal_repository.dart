import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';

import '../entities/goal.dart';

abstract class GoalRepository {
  Future<Either<Failure, Goal?>> getActiveGoal();

  Stream<Goal?> watchActiveGoal();

  Future<Either<Failure, Goal>> getGoalById(String id);

  Future<Either<Failure, Goal>> createGoal(Goal goal);

  Future<Either<Failure, Goal>> updateGoal(Goal goal);

  Future<Either<Failure, Unit>> deleteGoal(String id);
}
