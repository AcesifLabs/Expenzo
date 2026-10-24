import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/goals_dao.dart';

void main() {
  late AppDatabase db;
  late GoalsDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = GoalsDao(db);
  });

  tearDown(() => db.close());

  GoalsCompanion goal(String id, {DateTime? createdAt}) =>
      GoalsCompanion.insert(
        id: id,
        name: 'Goal $id',
        targetAmount: 1000,
        savedAmount: const Value(100),
        createdAt: Value(createdAt ?? DateTime.utc(2026, 1, 1)),
      );

  test('insert then read returns the same values, nulls included', () async {
    await dao.insertGoal(goal('g-1'));

    final read = await dao.getGoalById('g-1');

    expect(read?.name, 'Goal g-1');
    expect(read?.targetAmount, 1000);
    expect(read?.savedAmount, 100);
    expect(read?.targetDate, isNull);
    expect(read?.monthlyContribution, isNull);
  });

  test('updateGoal changes savedAmount', () async {
    await dao.insertGoal(goal('g-1'));
    final row = (await dao.getGoalById('g-1'))!;

    await dao.updateGoal(
      row.toCompanion(true).copyWith(savedAmount: const Value(400)),
    );

    expect((await dao.getGoalById('g-1'))?.savedAmount, 400);
  });

  test('deleteGoal removes the row', () async {
    await dao.insertGoal(goal('g-1'));

    await dao.deleteGoal('g-1');

    expect(await dao.getAllGoals(), isEmpty);
  });

  test('the active goal is the newest by createdAt', () async {
    await dao.insertGoal(goal('old', createdAt: DateTime.utc(2026, 1, 1)));
    await dao.insertGoal(goal('new', createdAt: DateTime.utc(2026, 5, 1)));

    expect((await dao.getActiveGoal())?.id, 'new');
  });

  test('watchActiveGoal follows inserts and deletes', () async {
    final ids = dao.watchActiveGoal().map((g) => g?.id);
    final expectation = expectLater(ids, emitsInOrder([null, 'g-1', null]));

    await pumpEventQueue();
    await dao.insertGoal(goal('g-1'));
    await pumpEventQueue();
    await dao.deleteGoal('g-1');

    await expectation;
  });
}
