import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';

import '../repositories/goal_repository.dart';

class DeleteGoal {
  final GoalRepository repository;

  DeleteGoal({required this.repository});

  Future<Either<Failure, Unit>> call(String id) => repository.deleteGoal(id);
}
