import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../sync_table_registry.dart';

class ExpenseTemplatesSyncHandler extends SyncTableHandler<$ExpenseTemplatesTable, ExpenseTemplate> {
  @override String get tableName => 'expense_templates';
  @override TableInfo<$ExpenseTemplatesTable, ExpenseTemplate> tableRef(AppDatabase db) => db.expenseTemplates;
  @override Map<String, dynamic> toSyncPayload(ExpenseTemplate row) => {
    'id': row.id, 'sourceId': row.sourceId, 'sampleMessage': row.sampleMessage, 'triggerWord': row.triggerWord, 'amountPattern': row.amountPattern,
    'descriptionPattern': row.descriptionPattern, 'datePattern': row.datePattern, 'categoryId': row.categoryId, 'selectedAmount': row.selectedAmount,
    'createdAt': row.createdAt.toUtc().toIso8601String(), 'updatedAt': row.updatedAt.toUtc().toIso8601String(),
  };
  @override Insertable<ExpenseTemplate> fromSyncPayload(String id, Map<String, dynamic> data) => ExpenseTemplatesCompanion.insert(
    id: id, sourceId: data['sourceId'] ?? '', sampleMessage: data['sampleMessage'] ?? '', triggerWord: data['triggerWord'] ?? '', amountPattern: data['amountPattern'] ?? '',
    descriptionPattern: data['descriptionPattern'] != null ? Value(data['descriptionPattern']) : const Value.absent(), datePattern: data['datePattern'] != null ? Value(data['datePattern']) : const Value.absent(),
    categoryId: data['categoryId'] != null ? Value(data['categoryId']) : const Value.absent(), selectedAmount: data['selectedAmount'] != null ? Value(data['selectedAmount']) : const Value.absent(),
    createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']).toLocal() : DateTime.now(), updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']).toLocal() : DateTime.now(),
  );
  @override Future<void> deleteById(AppDatabase db, String id) async => await (db.delete(db.expenseTemplates)..where((t) => t.id.equals(id))).go();
  @override Future<int> countRows(AppDatabase db) async { final count = countAll(); final query = db.selectOnly(db.expenseTemplates)..addColumns([count]); final result = await query.getSingle(); return result.read(count) ?? 0; }
  @override Future<List<ExpenseTemplate>> fetchAll(AppDatabase db) => db.select(db.expenseTemplates).get();
}
