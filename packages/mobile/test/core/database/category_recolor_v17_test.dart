import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/theme/category_palette.dart';

import 'migrations/v19_tables.dart';

/// Verifies the V16 -> V17 migration (category palette recolor):
///  - untouched default categories move to the new palette
///  - defaults the user recolored, and custom categories, keep their color
///  - every recolor is queued for sync with the full category payload
void main() {
  late File dbFile;

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('expenzo_v17_test');
    dbFile = File('${dir.path}/mig.sqlite');
  });

  tearDown(() async {
    if (await dbFile.exists()) await dbFile.delete();
  });

  Future<void> seedV16() async {
    final raw = NativeDatabase(dbFile);
    await raw.ensureOpen(_NoOpUser());
    await raw.runCustom('''
      CREATE TABLE categories (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        emoji TEXT NOT NULL DEFAULT 'package',
        color TEXT NOT NULL DEFAULT '#2196F3',
        is_default INTEGER NOT NULL DEFAULT 0,
        category_type TEXT NOT NULL DEFAULT 'OUT',
        usage_count INTEGER NOT NULL DEFAULT 0,
        user_id INTEGER,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
        updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now'))
      )
    ''', const []);
    await raw.runCustom('''
      CREATE TABLE sync_queue (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        entity_table TEXT NOT NULL,
        record_id TEXT NOT NULL,
        action TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
        synced_at INTEGER
      )
    ''', const []);
    // Every v16 install has budgets; later steps (v19) alter it.
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
    // Untouched default (old Bills gold), lower-case hex to check matching.
    await raw.runCustom(
      "INSERT INTO categories (id, name, emoji, color, is_default) "
      "VALUES ('default_out_bills', 'Bills & Utilities', 'lightning', '#ffd700', 1)",
      const [],
    );
    // Default the user recolored: must keep the user's choice.
    await raw.runCustom(
      "INSERT INTO categories (id, name, emoji, color, is_default) "
      "VALUES ('default_out_food', 'Food & Dining', 'forkKnife', '#123456', 1)",
      const [],
    );
    // A custom category that happens to use an old seed color.
    await raw.runCustom(
      "INSERT INTO categories (id, name, emoji, color, is_default) "
      "VALUES ('custom-1', 'Pets', 'pawPrint', '#FFD700', 0)",
      const [],
    );
    await addMissingV19Tables(raw, except: {'goals'});
    await raw.runCustom('PRAGMA user_version = 16', const []);
    await raw.close();
  }

  Future<String> colorOf(AppDatabase db, String id) async {
    final row = await db
        .customSelect(
          'SELECT color FROM categories WHERE id = ?',
          variables: [Variable.withString(id)],
        )
        .getSingle();

    return row.data['color'] as String;
  }

  test('recolors only untouched defaults and queues them for sync', () async {
    await seedV16();
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);

    expect(
      await colorOf(db, 'default_out_bills'),
      CategoryPalette.seedColors['default_out_bills'],
    );
    expect(await colorOf(db, 'default_out_food'), '#123456');
    expect(await colorOf(db, 'custom-1'), '#FFD700');

    final queued = await db.customSelect('SELECT * FROM sync_queue').get();
    expect(queued, hasLength(1));
    final row = queued.single.data;
    expect(row['entity_table'], 'categories');
    expect(row['record_id'], 'default_out_bills');
    expect(row['action'], 'update');
    final payload = jsonDecode(row['payload'] as String) as Map;
    expect(payload['color'], CategoryPalette.seedColors['default_out_bills']);
    expect(payload['name'], 'Bills & Utilities');
    expect(payload['type'], 'OUT');
    expect(payload['isDefault'], true);
  });

  test('every recolored seed has a rollback value and a palette color', () {
    expect(
      CategoryPalette.legacySeedColors.keys.toSet(),
      CategoryPalette.seedColors.keys.toSet(),
    );
    final paletteHexes = CategoryPalette.all.map((c) => c.hex).toSet();
    expect(paletteHexes.containsAll(CategoryPalette.seedColors.values), isTrue);
  });
}

class _NoOpUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 16;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
