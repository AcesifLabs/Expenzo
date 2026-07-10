import 'package:drift/drift.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import '../../database/app_database.dart';
import '../sync_table_registry.dart';
import 'sync_parse_helpers.dart';

class BudgetsSyncHandler extends SyncTableHandler<$BudgetsTable, Budget> {
  @override
  String get tableName => 'budgets';
  @override
  TableInfo<$BudgetsTable, Budget> tableRef(AppDatabase db) => db.budgets;
  @override
  Map<String, dynamic> toSyncPayload(Budget row) => {
    'id': row.id,
    'categoryId': row.categoryId,
    'amount': row.amount,
    'period': row.period,
    'startDate': row.startDate.toUtc().toIso8601String(),
    'rolloverEnabled': row.rolloverEnabled,
    'rolloverAmount': row.rolloverAmount,
    'isEnabled': row.isEnabled,
    'createdAt': row.createdAt.toUtc().toIso8601String(),
    'updatedAt': row.updatedAt.toUtc().toIso8601String(),
  };
  @override
  Insertable<Budget> fromSyncPayload(String id, Map<String, dynamic> data) =>
      BudgetsCompanion.insert(
        id: id,
        categoryId: data['categoryId'] != null
            ? Value(data['categoryId'].toString())
            : const Value.absent(),
        amount: parseSyncAmount(data['amount']),
        period: parseSyncString(data['period'], BudgetPeriod.monthly.name),
        startDate: parseSyncDate(data['startDate']),
        rolloverEnabled: data['rolloverEnabled'] != null
            ? Value(data['rolloverEnabled'] == true)
            : const Value.absent(),
        rolloverAmount: data['rolloverAmount'] != null
            ? Value(parseSyncAmount(data['rolloverAmount']))
            : const Value.absent(),
        isEnabled: data['isEnabled'] != null
            ? Value(data['isEnabled'] == true)
            : const Value.absent(),
        createdAt: data['createdAt'] != null
            ? Value(parseSyncDate(data['createdAt']))
            : const Value.absent(),
        updatedAt: data['updatedAt'] != null
            ? Value(parseSyncDate(data['updatedAt']))
            : const Value.absent(),
      );
  @override
  Future<void> deleteById(AppDatabase db, String id) async =>
      await (db.delete(db.budgets)..where((t) => t.id.equals(id))).go();
  @override
  Future<int> countRows(AppDatabase db) async {
    final c = countAll();
    final query = db.selectOnly(db.budgets)..addColumns([c]);
    final result = await query.getSingle();

    return result.read(c) ?? 0;
  }

  @override
  Future<List<Budget>> fetchAll(AppDatabase db) => db.select(db.budgets).get();
}
