import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';

import '../entities/goal.dart';
import '../repositories/goal_repository.dart';
import 'validate_goal.dart';

class CreateGoal {
  final GoalRepository repository;

  CreateGoal({required this.repository});

  Future<Either<Failure, Goal>> call(Goal goal) async {
    final failure = validateGoal(goal);
    if (failure != null) return Left(failure);

    return repository.createGoal(goal);
  }
}
