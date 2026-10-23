import 'package:drift/drift.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/database_seeder.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/sync/sync_table_names.dart';
import 'package:expense_tracker/core/sync/sync_table_registry.dart';

import '../../domain/entities/local_data_summary.dart';

abstract class DataWipeLocalDatasource {
  /// Throws: [CacheException]
  Future<LocalDataSummary> countData();

  /// Empties every table except the signed-in user, then adds the default
  /// categories back.
  ///
  /// Throws: [CacheException]
  Future<void> wipeLocalData();
}

class DataWipeLocalDatasourceImpl implements DataWipeLocalDatasource {
  final AppDatabase db;

  /// Counts reuse the sync handlers, which already know every synced table.
  final SyncTableRegistry registry;

  const DataWipeLocalDatasourceImpl({required this.db, required this.registry});

  @override
  Future<LocalDataSummary> countData() async {
    try {
      // Goals count only while a goals handler is registered; without one
      // the row stays hidden.
      final goals = registry[SyncTableNames.goals];
      final (
        transactions,
        budgets,
        categories,
        recurring,
        templates,
        rules,
      ) = await (
        _count(db.records),
        _count(db.budgets),
        _count(db.categories),
        _count(db.recurringTransactions),
        _count(db.expenseTemplates),
        _count(db.parsingRules),
      ).wait;

      return LocalDataSummary(
        transactions: transactions,
        budgets: budgets,
        categories: categories,
        recurring: recurring,
        smsRules: templates + rules,
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

  /// Rows in [table], through its sync handler; 0 when nothing syncs it.
  Future<int> _count(TableInfo<Table, Object?> table) async =>
      await registry[table.actualTableName]?.countRows(db) ?? 0;
}
