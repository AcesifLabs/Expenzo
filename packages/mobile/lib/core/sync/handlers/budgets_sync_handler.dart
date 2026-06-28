import 'package:drift/drift.dart';
import '../../../features/budgets/domain/entities/budget.dart'
    show BudgetPeriod;
import '../../database/app_database.dart';
import '../sync_table_registry.dart';

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
            ? Value(data['categoryId'])
            : const Value.absent(),
        amount: double.parse(data['amount'].toString()),
        period: data['period'] ?? BudgetPeriod.monthly.name,
        startDate: DateTime.parse(data['startDate']).toLocal(),
        rolloverEnabled: data['rolloverEnabled'] != null
            ? Value(data['rolloverEnabled'])
            : const Value.absent(),
        rolloverAmount: data['rolloverAmount'] != null
            ? Value(double.parse(data['rolloverAmount'].toString()))
            : const Value.absent(),
        isEnabled: data['isEnabled'] != null
            ? Value(data['isEnabled'])
            : const Value.absent(),
        createdAt: data['createdAt'] != null
            ? Value(DateTime.parse(data['createdAt']).toLocal())
            : const Value.absent(),
        updatedAt: data['updatedAt'] != null
            ? Value(DateTime.parse(data['updatedAt']).toLocal())
            : const Value.absent(),
      );
  @override
  Future<void> deleteById(AppDatabase db, String id) async =>
      await (db.delete(db.budgets)..where((t) => t.id.equals(id))).go();
  @override
  Future<int> countRows(AppDatabase db) async {
    final count = countAll();
    final query = db.selectOnly(db.budgets)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  @override
  Future<List<Budget>> fetchAll(AppDatabase db) => db.select(db.budgets).get();
}
