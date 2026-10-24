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
import 'tables/goals_table.dart';

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
import 'daos/goals_dao.dart';
import 'package:expense_tracker/core/theme/category_palette.dart';

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
    Goals,
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
    GoalsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  Future<String>? _dbPathFuture;

  @override
  int get schemaVersion => 19;

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

  Future<String> get dbPath => _dbPathFuture ??= _resolveDbPath();

  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  /// Empties every table and the search index. [keepUsers] keeps the
  /// signed-in user row, so the user stays signed in. [refill] runs in the
  /// same transaction, so no one sees the tables empty in between.
  Future<void> clearAllTables({
    bool keepUsers = false,
    Future<void> Function()? refill,
  }) async {
    await customStatement('PRAGMA foreign_keys = OFF');
    try {
      await transaction(() async {
        // First: the per-record delete trigger then finds an empty index
        // instead of scanning it once per record.
        await customStatement('DELETE FROM expense_fts');
        for (final table in allTables) {
          if (keepUsers && table == users) continue;
          await delete(table).go();
        }
        await refill?.call();
      });
    } finally {
      await customStatement('PRAGMA foreign_keys = ON');
    }
  }

  Future<String> _resolveDbPath() async {
    final dir = await getApplicationDocumentsDirectory();

    return p.join(dir.path, 'expenzo_db.sqlite');
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
      _MigrationStep(16, _migrateV16),
      _MigrationStep(17, _migrateV17),
      _MigrationStep(18, () => _migrateV18(m)),
      _MigrationStep(19, () => _migrateV19(m)),
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

  /// Moves untouched default categories to the new category palette.
  ///
  /// A default category is only recolored while it still has its old seed
  /// color, so colors the user picked are kept. Each change is queued for
  /// sync like a normal category edit, otherwise the next pull would restore
  /// the old color. Rollback: `CategoryPalette.legacySeedColors`.
  Future<void> _migrateV17() async {
    for (final MapEntry(key: id, value: oldColor)
        in CategoryPalette.legacySeedColors.entries) {
      final newColor = CategoryPalette.seedColors[id];
      if (newColor == null || newColor == oldColor) continue;
      final changed = await customUpdate(
        "UPDATE categories SET color = ?, updated_at = strftime('%s','now') "
        'WHERE id = ? AND is_default = 1 AND upper(color) = ?',
        variables: [
          Variable.withString(newColor),
          Variable.withString(id),
          Variable.withString(oldColor.toUpperCase()),
        ],
        updates: {categories},
      );
      if (changed == 0) continue;
      await customStatement(
        '''
        INSERT INTO sync_queue (entity_table, record_id, action, payload, created_at)
        SELECT 'categories', id, 'update',
               json_object(
                 'name', name, 'emoji', emoji, 'color', color,
                 'type', category_type,
                 'isDefault', json(CASE WHEN is_default THEN 'true' ELSE 'false' END)
               ),
               strftime('%s','now')
        FROM categories WHERE id = ?
        ''',
        [id],
      );
    }
  }

  /// Adds savings goals (SAAP-74, ADR 0009).
  Future<void> _migrateV18(Migrator m) async {
    await m.createTable(goals);
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_goals_user_id ON goals (user_id)',
    );
  }

  /// Marks Shared Budgets with their Family Group (SAAP-75, ADR 0008). No
  /// index: the table holds tens of rows.
  Future<void> _migrateV19(Migrator m) async {
    await m.addColumn(budgets, budgets.groupId);
  }

  Future<void> _migrateV16() async {
    // Rebuild budgets: drop category_id, add NOT NULL name (no backfill -> '').
    await customStatement('''
      CREATE TABLE budgets_new (
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
    ''');
    await customStatement('''
      INSERT INTO budgets_new (
        id, name, amount, period, start_date, rollover_enabled,
        rollover_amount, is_enabled, user_id, created_at, updated_at
      )
      SELECT id, '', amount, period, start_date, rollover_enabled,
             rollover_amount, is_enabled, user_id, created_at, updated_at
      FROM budgets
    ''');
    await customStatement('DROP TABLE budgets');
    await customStatement('ALTER TABLE budgets_new RENAME TO budgets');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_budgets_user_id ON budgets (user_id)',
    );

    // Add budget_id link to records (nullable; existing rows stay unlinked).
    await customStatement('ALTER TABLE records ADD COLUMN budget_id TEXT');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_records_budget_id ON records (budget_id)',
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
