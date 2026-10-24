import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart';

/// Verifies the V18 -> V19 migration (budgets.group_id, SAAP-75):
///  - existing budgets survive with group_id NULL
///  - a fresh install (onCreate) has the column too
void main() {
  late File dbFile;

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('expenzo_v19_test');
    dbFile = File('${dir.path}/mig.sqlite');
  });

  tearDown(() async {
    if (await dbFile.exists()) await dbFile.delete();
  });

  Future<void> seedV18() async {
    final raw = NativeDatabase(dbFile);
    await raw.ensureOpen(_NoOpUser());
    await raw.runCustom('''
      CREATE TABLE budgets (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL DEFAULT '',
        amount REAL NOT NULL,
        period TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        rollover_enabled INTEGER NOT NULL DEFAULT 0,
        rollover_amount REAL NOT NULL DEFAULT 0.0,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        user_id INTEGER,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
        updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now'))
      )
    ''', const []);
    await raw.runCustom(
      "INSERT INTO budgets (id, name, amount, period, start_date) "
      "VALUES ('bud-1', 'Groceries', 400, 'monthly', 0)",
      const [],
    );
    await raw.runCustom('PRAGMA user_version = 18', const []);
    await raw.close();
  }

  test('upgrading v18 keeps budgets and leaves group_id empty', () async {
    await seedV18();
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);

    final budget = await (db.select(
      db.budgets,
    )..where((t) => t.id.equals('bud-1'))).getSingle();
    expect(budget.name, 'Groceries');
    expect(budget.groupId, isNull);
  });

  test('a fresh install has budgets.group_id', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final rows = await db.customSelect('PRAGMA table_info(budgets)').get();
    expect(rows.map((row) => row.data['name']), contains('group_id'));
  });
}

class _NoOpUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 18;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
