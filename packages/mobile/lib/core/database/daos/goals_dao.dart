import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/goals_table.dart';

part 'goals_dao.g.dart';

@DriftAccessor(tables: [Goals])
class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  GoalsDao(super.db);

  Future<List<Goal>> getAllGoals() => select(goals).get();

  Future<Goal?> getGoalById(String id) {
    final query = select(goals)..where((g) => g.id.equals(id));

    return query.getSingleOrNull();
  }

  Future<void> insertGoal(GoalsCompanion goal) async {
    await into(goals).insert(goal);
  }

  Future<void> updateGoal(GoalsCompanion goal) async {
    await update(goals).replace(goal);
  }

  Future<void> deleteGoal(String id) async {
    await (delete(goals)..where((g) => g.id.equals(id))).go();
  }

  /// The goal the dashboard shows: the newest by createdAt, or null. A goal
  /// stays active after it is reached, until it is deleted or a newer one is
  /// added.
  Stream<Goal?> watchActiveGoal() => _activeGoal().watchSingleOrNull();

  Future<Goal?> getActiveGoal() => _activeGoal().getSingleOrNull();

  SimpleSelectStatement<$GoalsTable, Goal> _activeGoal() {
    return select(goals)
      ..orderBy([(g) => OrderingTerm.desc(g.createdAt)])
      ..limit(1);
  }
}
