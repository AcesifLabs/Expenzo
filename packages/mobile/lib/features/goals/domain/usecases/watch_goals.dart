import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

class WatchGoals {
  final GoalRepository repository;

  WatchGoals({required this.repository});

  Stream<List<Goal>> call() => repository.watchGoals();
}
