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
import 'tables/expense_fts_table.dart';

import 'daos/record_dao.dart';
import 'daos/category_dao.dart';
import 'daos/recurring_dao.dart';
import 'daos/budget_dao.dart';
import 'daos/pending_recurring_dao.dart';
import 'daos/parsing_rule_dao.dart';
import 'daos/message_template_dao.dart';

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
    ExpenseFtsTable,
  ],
  daos: [
    RecordDao,
    CategoryDao,
    RecurringDao,
    BudgetDao,
    PendingRecurringDao,
    ParsingRuleDao,
    MessageTemplateDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7;

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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'expenzo_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
