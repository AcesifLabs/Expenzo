import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';

import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

class GetActiveGoal {
  final GoalRepository repository;

  GetActiveGoal({required this.repository});

  Future<Either<Failure, Goal?>> call() => repository.getActiveGoal();
}
