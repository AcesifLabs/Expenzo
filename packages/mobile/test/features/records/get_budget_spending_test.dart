import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';

void main() {
  late AppDatabase db;
  late RecordDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = RecordDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insert({
    required String id,
    required double amount,
    required DateTime date,
    String? budgetId,
    String recordType = 'OUT',
  }) {
    return dao.insertRecord(
      RecordsCompanion.insert(
        id: id,
        amount: amount,
        description: 'x',
        date: date,
        recordType: recordType,
        budgetId: Value(budgetId),
      ),
    );
  }

  final start = DateTime(2026, 6, 1);
  final end = DateTime(2026, 7, 1); // exclusive upper bound (next period start)

  test('sums only expenses linked to the given budget in the period', () async {
    await insert(
      id: '1',
      amount: -40,
      date: DateTime(2026, 6, 10),
      budgetId: 'b1',
    );
    await insert(
      id: '2',
      amount: -20,
      date: DateTime(2026, 6, 20),
      budgetId: 'b1',
    );
    await insert(
      id: '3',
      amount: -99,
      date: DateTime(2026, 6, 15),
      budgetId: 'b2',
    );
    await insert(id: '4', amount: -10, date: DateTime(2026, 6, 15)); // unlinked

    final spend = await dao.getBudgetSpending('b1', start, end);

    expect(spend, 60.0);
  });

  test('excludes income records', () async {
    await insert(
      id: '1',
      amount: -40,
      date: DateTime(2026, 6, 10),
      budgetId: 'b1',
    );
    await insert(
      id: '2',
      amount: 500,
      date: DateTime(2026, 6, 10),
      budgetId: 'b1',
      recordType: 'IN',
    );

    final spend = await dao.getBudgetSpending('b1', start, end);

    expect(spend, 40.0);
  });

  test('includes a record dated exactly at period start', () async {
    await insert(id: '1', amount: -15, date: start, budgetId: 'b1');

    final spend = await dao.getBudgetSpending('b1', start, end);

    expect(spend, 15.0);
  });

  test('excludes a record dated exactly at period end (half-open)', () async {
    await insert(id: '1', amount: -15, date: end, budgetId: 'b1');

    final spend = await dao.getBudgetSpending('b1', start, end);

    expect(spend, 0.0);
  });

  test('returns 0.0 when the budget has no matching records', () async {
    await insert(
      id: '1',
      amount: -40,
      date: DateTime(2026, 6, 10),
      budgetId: 'other',
    );

    final spend = await dao.getBudgetSpending('b1', start, end);

    expect(spend, 0.0);
  });
}
