import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
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

import '../constants/source_types.dart';
import '../constants/record_type.dart';

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
  @override
  int get schemaVersion => 15;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _createFtsTable(customStatement);
      await _createFtsTriggers(customStatement);
    },
    onUpgrade: (Migrator m, int from, int to) async {
      await _runMigrations(m, from);
    },
  );

  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  Future<String>? _dbPathFuture;

  Future<String> get dbPath => _dbPathFuture ??= _resolveDbPath();

  Future<String> _resolveDbPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, 'expenzo_db.sqlite');
  }

  Future<void> clearAllTables() async {
    await customStatement('PRAGMA foreign_keys = OFF');
    try {
      await transaction(() async {
        for (final table in allTables) {
          await delete(table).go();
        }
        await customStatement('DELETE FROM expense_fts');
      });
    } finally {
      await customStatement('PRAGMA foreign_keys = ON');
    }
  }

  Future<void> _runMigrations(Migrator m, int from) async {
    final steps = <_MigrationStep>[
      _MigrationStep(2, () => _migrateToV2(m)),
      _MigrationStep(3, () => _migrateToV3(m)),
      _MigrationStep(5, _migrateToV5),
      _MigrationStep(6, () => _migrateToV6(m)),
      _MigrationStep(7, () => _migrateToV7(m)),
      _MigrationStep(8, () => _migrateToV8(m)),
      _MigrationStep(9, () => _migrateToV9(m)),
      _MigrationStep(10, () => _migrateToV10(m)),
      _MigrationStep(11, () => _migrateToV11(m)),
      _MigrationStep(12, _migrateV12),
      _MigrationStep(13, _migrateV13),
      _MigrationStep(14, _migrateV14),
      _MigrationStep(15, _migrateV15),
    ];

    for (final step in steps) {
      if (from < step.version) {
        await step.migrate();
      }
    }
  }

  Future<void> _migrateToV2(Migrator m) async {
    await m.createTable(messageSources);
    await m.createTable(expenseTemplates);
  }

  Future<void> _migrateToV3(Migrator m) async {
    await m.createTable(budgets);
  }

  Future<void> _migrateToV5() async {
    await _createFtsTable(customStatement);
    await _createFtsTriggers(customStatement);
  }

  Future<void> _migrateToV6(Migrator m) async {
    await m.renameTable(records, 'expenses');
    await m.addColumn(records, records.recordType);
    await m.addColumn(categories, categories.categoryType);

    await customStatement("UPDATE records SET record_type = 'OUT'");
    await customStatement("UPDATE categories SET category_type = 'OUT'");

    await customStatement("DROP TRIGGER IF EXISTS expenses_ai");
    await customStatement("DROP TRIGGER IF EXISTS expenses_ad");
    await customStatement("DROP TRIGGER IF EXISTS expenses_au");
    await _createFtsTriggers(customStatement);
  }

  Future<void> _migrateToV7(Migrator m) async {
    await m.addColumn(categories, categories.usageCount);
  }

  Future<void> _migrateToV8(Migrator m) async {
    await m.createTable(users);
  }

  Future<void> _migrateToV9(Migrator m) async {
    await m.addColumn(records, records.userId);
    await m.addColumn(categories, categories.userId);
    await m.addColumn(budgets, budgets.userId);
  }

  Future<void> _migrateToV10(Migrator m) async {
    await m.createTable(syncQueue);
  }

  Future<void> _migrateToV11(Migrator m) async {
    await m.createTable(appSettings);
  }

  Future<void> _migrateV12() async {
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
    await customStatement('ALTER TABLE categories_new RENAME TO categories');

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
    await customStatement('ALTER TABLE records_new RENAME TO records');

    await customStatement('CREATE INDEX idx_records_date ON records (date)');
    await customStatement(
      'CREATE INDEX idx_records_category ON records (category_id)',
    );
    await customStatement(
      'CREATE INDEX idx_records_source_id ON records (source_id)',
    );

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

    await customStatement('DELETE FROM expense_fts');
    await customStatement('''
      INSERT INTO expense_fts (expense_id, description)
      SELECT id, description FROM records
    ''');
    await _createFtsTriggers(customStatement);
  }

  Future<void> _migrateV13() async {
    await customStatement('DROP TABLE IF EXISTS expense_fts');
    await _createFtsTable(customStatement);
    await customStatement('''
      INSERT INTO expense_fts (expense_id, description)
      SELECT id, description FROM records
    ''');
    await _createFtsTriggers(customStatement);
  }

  Future<void> _migrateV14() async {
    // Remove duplicate category rows, keeping the most recently updated one
    await customStatement('''
      DELETE FROM categories
      WHERE rowid NOT IN (
        SELECT MAX(rowid) FROM categories GROUP BY id
      )
    ''');
  }

  Future<void> _migrateV15() async {
    final queries = [
      'CREATE INDEX IF NOT EXISTS idx_records_user_id ON records (user_id)',
      'CREATE INDEX IF NOT EXISTS idx_categories_user_id ON categories (user_id)',
      'CREATE INDEX IF NOT EXISTS idx_budgets_category_id ON budgets (category_id)',
      'CREATE INDEX IF NOT EXISTS idx_budgets_user_id ON budgets (user_id)',
      'CREATE INDEX IF NOT EXISTS idx_pending_recurring_req_id ON pending_recurring (recurring_id)',
      'CREATE INDEX IF NOT EXISTS idx_pending_recurring_cat_id ON pending_recurring (category_id)',
      'CREATE INDEX IF NOT EXISTS idx_recurring_transactions_cat_id ON recurring_transactions (category_id)',
      'CREATE INDEX IF NOT EXISTS idx_expense_templates_source_id ON expense_templates (source_id)',
      'CREATE INDEX IF NOT EXISTS idx_expense_templates_cat_id ON expense_templates (category_id)',
      'CREATE INDEX IF NOT EXISTS idx_parsing_rules_cat_id ON parsing_rules (category_id)',
    ];

    for (final query in queries) {
      await customStatement(query);
    }
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
    await executor('''
      CREATE TRIGGER IF NOT EXISTS records_ai AFTER INSERT ON records BEGIN
        INSERT INTO expense_fts(expense_id, description)
        VALUES (new.id, new.description);
      END;
    ''');

    await executor('''
      CREATE TRIGGER IF NOT EXISTS records_ad AFTER DELETE ON records BEGIN
        DELETE FROM expense_fts WHERE expense_id = old.id;
      END;
    ''');

    await executor('''
      CREATE TRIGGER IF NOT EXISTS records_au AFTER UPDATE ON records BEGIN
        UPDATE expense_fts SET description = new.description
        WHERE expense_id = old.id;
      END;
    ''');
  }
}

class _MigrationStep {
  final int version;
  final Future<void> Function() migrate;

  const _MigrationStep(this.version, this.migrate);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'expenzo_db.sqlite'));

    return NativeDatabase.createInBackground(file, logStatements: kDebugMode);
  });
}
