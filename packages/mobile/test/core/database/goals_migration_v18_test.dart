import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart';

import 'migrations/v19_tables.dart';

void main() {
  late File dbFile;

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('expenzo_v18_test');
    dbFile = File('${dir.path}/mig.sqlite');
  });

  tearDown(() async {
    if (await dbFile.exists()) await dbFile.delete();
  });

  Future<void> seedV17() async {
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
    await addMissingV19Tables(raw, except: {'goals'});
    await raw.runCustom('PRAGMA user_version = 17', const []);
    await raw.close();
  }

  Future<List<String>> columnsOf(AppDatabase db, String table) async {
    final rows = await db.customSelect('PRAGMA table_info($table)').get();

    return [for (final row in rows) row.data['name'] as String];
  }

  test('upgrading v17 adds goals and keeps other rows', () async {
    await seedV17();
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);

    expect(await columnsOf(db, 'goals'), [
      'id',
      'name',
      'target_amount',
      'saved_amount',
      'target_date',
      'monthly_contribution',
      'user_id',
      'created_at',
      'updated_at',
    ]);
    final indexes = await db.customSelect('PRAGMA index_list(goals)').get();
    expect(
      indexes.map((row) => row.data['name']),
      contains('idx_goals_user_id'),
    );
    final budgets = await db
        .customSelect("SELECT name FROM budgets WHERE id = 'bud-1'")
        .get();
    expect(budgets.single.data['name'], 'Groceries');
  });

  test('a goal saved without saved_amount stores 0', () async {
    await seedV17();
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);

    await db.customStatement(
      "INSERT INTO goals (id, name, target_amount) VALUES ('g-1', 'Laptop', 1999)",
    );

    final row = await db
        .customSelect("SELECT saved_amount FROM goals WHERE id = 'g-1'")
        .getSingle();
    expect(row.data['saved_amount'], 0.0);
  });

  test('a fresh install has the goals table', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await columnsOf(db, 'goals'), contains('target_amount'));
  });
}

class _NoOpUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 17;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
