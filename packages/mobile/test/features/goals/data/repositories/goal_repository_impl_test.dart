import 'dart:convert';

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
  late SyncQueueDao queue;
  late GoalRepositoryImpl repository;
  final date = DateTime.utc(2027, 1, 24);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    queue = SyncQueueDao(db);
    repository = GoalRepositoryImpl(
      localDatasource: GoalLocalDatasourceImpl(goalsDao: GoalsDao(db)),
      syncQueueDao: queue,
    );
  });

  tearDown(() => db.close());

  Goal goal({DateTime? targetDate}) => Goal(
    name: 'Laptop',
    targetAmount: 1999,
    savedAmount: 250,
    targetDate: targetDate,
    monthlyContribution: 583.17,
  );

  Future<Goal> created({DateTime? targetDate}) async =>
      (await repository.createGoal(
        goal(targetDate: targetDate),
      )).getOrElse(() => throw StateError('create failed'));

  test(
    'createGoal assigns an id and queues an insert with the fields',
    () async {
      final saved = await created(targetDate: date);

      expect(saved.id, isNotEmpty);
      final rows = await queue.getUnsynced();
      expect(rows.single.entityTable, 'goals');
      expect(rows.single.action, 'insert');
      expect(rows.single.recordId, saved.id);
      expect(jsonDecode(rows.single.payload), {
        'name': 'Laptop',
        'targetAmount': 1999.0,
        'savedAmount': 250.0,
        'targetDate': date.toIso8601String(),
        'monthlyContribution': 583.17,
      });
    },
  );

  test('updateGoal queues an update with the new savedAmount', () async {
    final saved = await created();

    await repository.updateGoal(saved.copyWith(savedAmount: 400));

    final update = (await queue.getUnsynced()).last;
    expect(update.action, 'update');
    expect((jsonDecode(update.payload) as Map)['savedAmount'], 400.0);
    expect(
      (await repository.getGoalById(
        saved.id!,
      )).fold((_) => null, (g) => g.savedAmount),
      400,
    );
  });

  test('deleteGoal removes the row and queues an empty delete', () async {
    final saved = await created();

    await repository.deleteGoal(saved.id!);

    final delete = (await queue.getUnsynced()).last;
    expect(delete.action, 'delete');
    expect(delete.payload, '');
    expect(
      (await repository.getActiveGoal()).fold((_) => 'failed', (g) => g),
      isNull,
    );
  });

  test('watchActiveGoal emits the mapped goal', () async {
    final saved = await created(targetDate: date);

    final active = await repository.watchActiveGoal().first;

    expect(active?.id, saved.id);
    expect(active?.name, 'Laptop');
    expect(active?.targetAmount, 1999);
    expect(active?.savedAmount, 250);
    expect(active?.targetDate?.isAtSameMomentAs(date), isTrue);
    expect(active?.monthlyContribution, 583.17);
  });

  test('a null targetDate round-trips as null', () async {
    final saved = await created();

    final read = (await repository.getGoalById(
      saved.id!,
    )).fold((_) => null, (g) => g);
    expect(read?.targetDate, isNull);
    expect(read?.name, 'Laptop');
  });
}
