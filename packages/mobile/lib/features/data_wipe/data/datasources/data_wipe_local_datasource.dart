import 'package:drift/drift.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/database_seeder.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/sync/sync_table_names.dart';
import 'package:expense_tracker/core/sync/sync_table_registry.dart';

import '../../domain/entities/local_data_summary.dart';

abstract class DataWipeLocalDatasource {
  Future<LocalDataSummary> countData();

  Future<void> wipeLocalData();
}

class DataWipeLocalDatasourceImpl implements DataWipeLocalDatasource {
  final AppDatabase db;

  final SyncTableRegistry registry;

  const DataWipeLocalDatasourceImpl({required this.db, required this.registry});

  @override
  Future<LocalDataSummary> countData() async {
    try {
      final goals = registry[SyncTableNames.goals];
      final (transactions, budgets, categories, recurring, templates) = await (
        _count(db.records),
        _count(db.budgets),
        _count(db.categories),
        _count(db.recurringTransactions),
        _count(db.expenseTemplates),
      ).wait;

      return LocalDataSummary(
        transactions: transactions,
        budgets: budgets,
        categories: categories,
        recurring: recurring,
        smsRules: templates,
        goals: goals == null ? null : await goals.countRows(db),
      );
    } catch (e, s) {
      appLogger.error('Data wipe local datasource error', e, s);
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> wipeLocalData() async {
    try {
      await db.clearAllTables(
        keepUsers: true,
        refill: () => DatabaseSeeder.seedInitialCategories(db),
      );
    } catch (e, s) {
      appLogger.error('Data wipe local datasource error', e, s);
      throw CacheException(message: e.toString());
    }
  }

  Future<int> _count(TableInfo<Table, Object?> table) async =>
      await registry[table.actualTableName]?.countRows(db) ?? 0;
}
