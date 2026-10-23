import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/error/failures.dart';

import '../entities/goal.dart';
import '../repositories/goal_repository.dart';
import 'validate_goal.dart';

class UpdateGoal {
  final GoalRepository repository;

  UpdateGoal({required this.repository});

  Future<Either<Failure, Goal>> call(Goal goal) async {
    if (goal.id == null) {
      return const Left(
        CacheFailure(
          message: 'A goal needs an id to update',
          errorCode: FailureCodes.notFound,
        ),
      );
    }
    final failure = validateGoal(goal);
    if (failure != null) return Left(failure);

    return repository.updateGoal(goal);
  }
}
