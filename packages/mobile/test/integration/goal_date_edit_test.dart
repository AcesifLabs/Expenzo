import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart' hide Goal;
import 'package:expense_tracker/core/database/daos/goals_dao.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/features/goals/data/datasources/goal_local_datasource.dart';
import 'package:expense_tracker/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';

void main() {
  late AppDatabase db;
  late GoalRepositoryImpl repository;
  final now = DateTime(2026, 11, 1, 10);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = GoalRepositoryImpl(
      localDatasource: GoalLocalDatasourceImpl(goalsDao: GoalsDao(db)),
      syncQueueDao: SyncQueueDao(db),
    );
  });

  tearDown(() => db.close());

  test(
    'editing the target date changes monthsLeft on the watched goal',
    () async {
      final created = (await repository.createGoal(
        Goal(
          name: 'Laptop',
          targetAmount: 900,
          targetDate: DateTime(2027, 2, 1, 10),
          monthlyContribution: 300,
        ),
      )).getOrElse(() => throw StateError('create failed'));
      expect(created.monthsLeft(now), 3);
      final months = repository.watchGoals().map(
        (goals) => goals.single.monthsLeft(now),
      );
      final seen = expectLater(months, emitsInOrder([3, 8]));
      await pumpEventQueue();

      await repository.updateGoal(
        created.copyWith(targetDate: DateTime(2027, 7, 1)),
      );

      await seen;
    },
  );
}
