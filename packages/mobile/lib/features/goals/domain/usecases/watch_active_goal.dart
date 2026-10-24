import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

class WatchActiveGoal {
  final GoalRepository repository;

  WatchActiveGoal({required this.repository});

  Stream<Goal?> call() => repository.watchActiveGoal();
}
