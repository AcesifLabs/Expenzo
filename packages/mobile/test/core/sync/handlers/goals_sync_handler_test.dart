import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/sync/default_sync_registry.dart';
import 'package:expense_tracker/core/sync/handlers/goals_sync_handler.dart';

void main() {
  late AppDatabase db;
  final handler = GoalsSyncHandler();

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Map<String, dynamic> payload({
    Object? targetDate = '2027-01-24T00:00:00.000Z',
  }) => {
    'name': 'Laptop',
    'targetAmount': '1999.00',
    'savedAmount': '250.50',
    'targetDate': targetDate,
    'monthlyContribution': '583.17',
    'createdAt': '2026-10-24T10:00:00.000Z',
    'updatedAt': '2026-10-24T11:00:00.000Z',
  };

  Future<Goal> pullAndRead(Map<String, dynamic> data) async {
    await db.into(db.goals).insert(handler.fromSyncPayload('g-1', data));

    return (await handler.fetchAll(db)).single;
  }

  test('string decimals from Postgres become doubles', () async {
    final goal = await pullAndRead(payload());

    expect(goal.targetAmount, 1999.0);
    expect(goal.savedAmount, 250.5);
    expect(goal.monthlyContribution, 583.17);
  });

  test(
    'a null targetDate and a missing monthlyContribution stay null',
    () async {
      final goal = await pullAndRead(
        payload(targetDate: null)..remove('monthlyContribution'),
      );

      expect(goal.targetDate, isNull);
      expect(goal.monthlyContribution, isNull);
    },
  );

  test('toSyncPayload round-trips every field', () async {
    final goal = await pullAndRead(payload());

    final out = handler.toSyncPayload(goal);

    expect(out['id'], 'g-1');
    expect(out['name'], 'Laptop');
    expect(out['targetAmount'], 1999.0);
    expect(out['savedAmount'], 250.5);
    expect(out['monthlyContribution'], 583.17);
    expect(
      DateTime.parse(out['targetDate'] as String),
      DateTime.utc(2027, 1, 24),
    );
    expect(
      DateTime.parse(out['createdAt'] as String),
      DateTime.utc(2026, 10, 24, 10),
    );
    expect(
      DateTime.parse(out['updatedAt'] as String),
      DateTime.utc(2026, 10, 24, 11),
    );
  });

  test('countRows and deleteById work', () async {
    await pullAndRead(payload());

    expect(await handler.countRows(db), 1);
    await handler.deleteById(db, 'g-1');
    expect(await handler.countRows(db), 0);
  });

  test('the default registry has the goals handler', () {
    expect(createDefaultSyncRegistry()['goals'], isA<GoalsSyncHandler>());
  });
}
