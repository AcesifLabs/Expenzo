import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/expenses_table.dart';
import 'tables/categories_table.dart';
import 'tables/pending_recurring_table.dart';
import 'tables/parsing_rules_table.dart';
import 'tables/message_sources_table.dart';
import 'tables/expense_templates_table.dart';
import 'tables/budgets_table.dart';
import 'tables/recurring_table.dart';
import 'tables/expense_fts_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Expenses,
    Categories,
    PendingRecurring,
    ParsingRules,
    MessageSources,
    ExpenseTemplates,
    Budgets,
    RecurringTransactions,
    ExpenseFtsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await customStatement('''
          CREATE VIRTUAL TABLE IF NOT EXISTS expense_fts USING fts5(
            expense_id UNINDEXED,
            description
          )
        ''');
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
          await customStatement('''
            CREATE VIRTUAL TABLE IF NOT EXISTS expense_fts USING fts5(
              expense_id UNINDEXED,
              description
            )
          ''');
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'expenzo_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
