import 'package:drift/drift.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/goals_dao.dart';
import 'package:expense_tracker/core/error/exceptions.dart';

import '../../domain/entities/goal.dart' as domain;

abstract class GoalLocalDatasource {
  Future<domain.Goal?> getActiveGoal();
  Stream<List<domain.Goal>> watchGoals();
  Future<domain.Goal?> getGoalById(String id);

  Future<void> createGoal(domain.Goal goal);
  Future<void> updateGoal(domain.Goal goal);
  Future<void> deleteGoal(String id);
}

class GoalLocalDatasourceImpl implements GoalLocalDatasource {
  final GoalsDao goalsDao;

  GoalLocalDatasourceImpl({required this.goalsDao});

  @override
  Future<domain.Goal?> getActiveGoal() =>
      _guard(() async => _toEntityOrNull(await goalsDao.getActiveGoal()));

  @override
  Stream<List<domain.Goal>> watchGoals() =>
      goalsDao.watchGoals().map((rows) => rows.map(_toEntity).toList());

  @override
  Future<domain.Goal?> getGoalById(String id) =>
      _guard(() async => _toEntityOrNull(await goalsDao.getGoalById(id)));

  @override
  Future<void> createGoal(domain.Goal goal) => _guard(() {
    final now = DateTime.now().toUtc();

    return goalsDao.insertGoal(
      _toCompanion(goal, createdAt: goal.createdAt ?? now, updatedAt: now),
    );
  });

  @override
  Future<void> updateGoal(domain.Goal goal) => _guard(() async {
    final stored = await goalsDao.getGoalById(goal.id ?? '');
    if (stored == null) {
      throw CacheException(message: 'Goal ${goal.id} not found');
    }

    await goalsDao.updateGoal(
      _toCompanion(
        goal,
        createdAt: stored.createdAt,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  });

  @override
  Future<void> deleteGoal(String id) => _guard(() => goalsDao.deleteGoal(id));

  GoalsCompanion _toCompanion(
    domain.Goal goal, {
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return GoalsCompanion(
      id: Value(goal.id ?? ''),
      name: Value(goal.name),
      targetAmount: Value(roundMoney(goal.targetAmount)),
      savedAmount: Value(roundMoney(goal.savedAmount)),
      targetDate: Value(goal.targetDate),
      monthlyContribution: Value(goal.monthlyContribution),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  domain.Goal? _toEntityOrNull(Goal? row) =>
      row == null ? null : _toEntity(row);

  domain.Goal _toEntity(Goal row) {
    return domain.Goal(
      id: row.id,
      name: row.name,
      targetAmount: row.targetAmount,
      savedAmount: row.savedAmount,
      targetDate: row.targetDate,
      monthlyContribution: row.monthlyContribution,
      createdAt: row.createdAt,
    );
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
}
