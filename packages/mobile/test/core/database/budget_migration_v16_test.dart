import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart';

/// Verifies the V15 -> V16 migration:
///  - budgets: category_id dropped, NOT NULL name added (legacy rows -> '')
///  - records: budget_id column added (nullable; legacy rows -> null)
///  - idx_budgets_category_id removed, idx_records_budget_id created
void main() {
  late File dbFile;

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('expenzo_mig_test');
    dbFile = File('${dir.path}/mig.sqlite');
  });

  tearDown(() async {
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
  });

  /// Seeds a physical SQLite file with the V15-shaped budgets/records schema
  /// and sets user_version = 15 so reopening as AppDatabase triggers onUpgrade.
  Future<void> seedV15Schema() async {
    final raw = NativeDatabase(dbFile);
    // Minimal V15 shapes for the two tables the migration touches.
    await raw.ensureOpen(_NoOpUser());
    await raw.runCustom('''
      CREATE TABLE budgets (
        id TEXT NOT NULL PRIMARY KEY,
        category_id TEXT,
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
      'CREATE INDEX idx_budgets_category_id ON budgets (category_id)',
      const [],
    );
    await raw.runCustom('''
      CREATE TABLE records (
        id TEXT NOT NULL PRIMARY KEY,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        date INTEGER NOT NULL,
        category_id TEXT,
        source TEXT NOT NULL DEFAULT 'manual',
        source_id TEXT,
        record_type TEXT NOT NULL,
        user_id INTEGER,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
        updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now'))
      )
    ''', const []);
    await raw.runCustom(
      "INSERT INTO budgets (id, category_id, amount, period, start_date) "
      "VALUES ('b1', 'cat-1', 500.0, 'monthly', 0)",
      const [],
    );
    await raw.runCustom(
      "INSERT INTO records (id, amount, description, date, record_type) VALUES ('r1', -20.0, 'Old expense', 0, 'OUT')",
      const [],
    );
    await raw.runCustom('PRAGMA user_version = 15', const []);
    await raw.close();
  }

  Future<List<String>> tableColumns(AppDatabase db, String table) async {
    final rows = await db.customSelect('PRAGMA table_info($table)').get();
    return rows.map((r) => r.data['name'] as String).toList();
  }

  Future<List<String>> indexNames(AppDatabase db, String table) async {
    final rows = await db.customSelect('PRAGMA index_list($table)').get();
    return rows.map((r) => r.data['name'] as String).toList();
  }

  test('migrates budgets and records from V15 to V16', () async {
    await seedV15Schema();

    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    // Force the migration to run by touching the DB.
    await db.customSelect('SELECT 1').get();

    final budgetCols = await tableColumns(db, 'budgets');
    expect(budgetCols, contains('name'));
    expect(budgetCols, isNot(contains('category_id')));

    final recordCols = await tableColumns(db, 'records');
    expect(recordCols, contains('budget_id'));

    final budgetIdxs = await indexNames(db, 'budgets');
    expect(budgetIdxs, isNot(contains('idx_budgets_category_id')));

    final recordIdxs = await indexNames(db, 'records');
    expect(recordIdxs, contains('idx_records_budget_id'));

    // Legacy rows survive: budget name backfilled to '', record budget_id null.
    final budgetRow = await db
        .customSelect("SELECT name FROM budgets WHERE id = 'b1'")
        .getSingle();
    expect(budgetRow.data['name'], '');

    final recordRow = await db
        .customSelect("SELECT budget_id FROM records WHERE id = 'r1'")
        .getSingle();
    expect(recordRow.data['budget_id'], null);

    await db.close();
  });
}

class _NoOpUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 15;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
