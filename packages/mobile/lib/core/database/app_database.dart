import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/records_table.dart';
import 'tables/categories_table.dart';
import 'tables/pending_recurring_table.dart';
import 'tables/parsing_rules_table.dart';
import 'tables/message_sources_table.dart';
import 'tables/expense_templates_table.dart';
import 'tables/budgets_table.dart';
import 'tables/recurring_table.dart';
import 'tables/users_table.dart';
import 'tables/sync_queue_table.dart';
import 'tables/app_settings_table.dart';

import 'daos/record_dao.dart';
import 'daos/category_dao.dart';
import 'daos/recurring_dao.dart';
import 'daos/budget_dao.dart';
import 'daos/pending_recurring_dao.dart';
import 'daos/parsing_rule_dao.dart';
import 'daos/message_template_dao.dart';
import 'daos/user_dao.dart';
import 'daos/sync_queue_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Records,
    Categories,
    PendingRecurring,
    ParsingRules,
    MessageSources,
    ExpenseTemplates,
    Budgets,
    RecurringTransactions,
    Users,
    SyncQueue,
    AppSettings,
  ],
  daos: [
    RecordDao,
    CategoryDao,
    RecurringDao,
    BudgetDao,
    PendingRecurringDao,
    ParsingRuleDao,
    MessageTemplateDao,
    UserDao,
    SyncQueueDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createFtsTable(customStatement);
        await _createFtsTriggers(customStatement);
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(messageSources);
          await m.createTable(expenseTemplates);
        }
        if (from < 3) {
          await m.createTable(budgets);
        }
        if (from < 5) {
          await _createFtsTable(customStatement);
          await _createFtsTriggers(customStatement);
        }
        if (from < 6) {
          // Rename expenses to records
          await m.renameTable(records, 'expenses');
          await m.addColumn(records, records.recordType);
          await m.addColumn(categories, categories.categoryType);

          await customStatement("UPDATE records SET record_type = 'OUT'");
          await customStatement("UPDATE categories SET category_type = 'OUT'");

          // Update FTS triggers
          await customStatement("DROP TRIGGER IF EXISTS expenses_ai");
          await customStatement("DROP TRIGGER IF EXISTS expenses_ad");
          await customStatement("DROP TRIGGER IF EXISTS expenses_au");
          await _createFtsTriggers(customStatement);
        }
        if (from < 7) {
          await m.addColumn(categories, categories.usageCount);
        }
        if (from < 8) {
          await m.createTable(users);
        }
        if (from < 9) {
          await m.addColumn(records, records.userId);
          await m.addColumn(categories, categories.userId);
          await m.addColumn(budgets, budgets.userId);
        }
        if (from < 10) {
          await m.createTable(syncQueue);
        }
        if (from < 11) {
          await m.createTable(appSettings);
        }
        if (from < 12) {
          // ── Categories: int id → text id ──
          await customStatement('DROP TRIGGER IF EXISTS records_ai');
          await customStatement('DROP TRIGGER IF EXISTS records_ad');
          await customStatement('DROP TRIGGER IF EXISTS records_au');

          await customStatement('''
            CREATE TABLE categories_new (
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
          ''');
          await customStatement('''
            INSERT INTO categories_new
            SELECT CAST(id AS TEXT), name, emoji, color, is_default,
                   category_type, usage_count, user_id, created_at, updated_at
            FROM categories
          ''');
          await customStatement('DROP TABLE categories');
          await customStatement(
            'ALTER TABLE categories_new RENAME TO categories',
          );

          // ── Records: int id → text, int categoryId → text ──
          await customStatement('''
            CREATE TABLE records_new (
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
          ''');
          await customStatement('''
            INSERT INTO records_new
            SELECT CAST(id AS TEXT), amount, description, date,
                   CAST(category_id AS TEXT), source, source_id,
                   record_type, user_id, created_at, updated_at
            FROM records
          ''');
          await customStatement('DROP TABLE records');
          await customStatement(
            'ALTER TABLE records_new RENAME TO records',
          );

          // Recreate indexes
          await customStatement(
            'CREATE INDEX idx_records_date ON records (date)',
          );
          await customStatement(
            'CREATE INDEX idx_records_category ON records (category_id)',
          );
          await customStatement(
            'CREATE INDEX idx_records_source_id ON records (source_id)',
          );

          // ── PendingRecurring: int id → text ──
          await customStatement('''
            CREATE TABLE pending_recurring_new (
              id TEXT NOT NULL PRIMARY KEY,
              recurring_id TEXT NOT NULL,
              due_date INTEGER NOT NULL,
              amount REAL NOT NULL,
              description TEXT NOT NULL,
              category_id TEXT,
              created_at INTEGER NOT NULL DEFAULT (strftime('%s','now'))
            )
          ''');
          await customStatement('''
            INSERT INTO pending_recurring_new
            SELECT CAST(id AS TEXT), recurring_id, due_date, amount,
                   description, category_id, created_at
            FROM pending_recurring
          ''');
          await customStatement('DROP TABLE pending_recurring');
          await customStatement(
            'ALTER TABLE pending_recurring_new RENAME TO pending_recurring',
          );

          // ── FTS: rebuild with text IDs ──
          await customStatement('DELETE FROM expense_fts');
          await customStatement('''
            INSERT INTO expense_fts (expense_id, description)
            SELECT id, description FROM records
          ''');

          // Recreate FTS triggers
          await _createFtsTriggers(customStatement);
        }
        if (from < 13) {
          // ── FTS: Drift managed ExpenseFtsTable as regular table ──
          // Drop the regular table (created by m.createAll() pre-v13).
          // Recreate as proper virtual FTS5 table.
          await customStatement('DROP TABLE IF EXISTS expense_fts');
          await _createFtsTable(customStatement);
          await customStatement('''
            INSERT INTO expense_fts (expense_id, description)
            SELECT id, description FROM records
          ''');
          await _createFtsTriggers(customStatement);
        }
      },
    );
  }

  Future<void> _createFtsTable(Future<void> Function(String) executor) async {
    await executor('''
      CREATE VIRTUAL TABLE IF NOT EXISTS expense_fts USING fts5(
        expense_id UNINDEXED,
        description
      )
    ''');
  }

  Future<void> _createFtsTriggers(
    Future<void> Function(String) executor,
  ) async {
    // INSERT Trigger
    await executor('''
      CREATE TRIGGER IF NOT EXISTS records_ai AFTER INSERT ON records BEGIN
        INSERT INTO expense_fts(expense_id, description) 
        VALUES (new.id, new.description);
      END;
    ''');

    // DELETE Trigger
    await executor('''
      CREATE TRIGGER IF NOT EXISTS records_ad AFTER DELETE ON records BEGIN
        DELETE FROM expense_fts WHERE expense_id = old.id;
      END;
    ''');

    // UPDATE Trigger
    await executor('''
      CREATE TRIGGER IF NOT EXISTS records_au AFTER UPDATE ON records BEGIN
        UPDATE expense_fts SET description = new.description 
        WHERE expense_id = old.id;
      END;
    ''');
  }

  Future<void> clearAllTables() async {
    await customStatement('PRAGMA foreign_keys = OFF');
    try {
      await transaction(() async {
        for (final table in allTables) {
          await delete(table).go();
        }
        // Virtual FTS5 table (not managed by Drift, deleted separately)
        await customStatement('DELETE FROM expense_fts');
      });
    } finally {
      await customStatement('PRAGMA foreign_keys = ON');
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'expenzo_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
