import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../sync_table_registry.dart';

class ExpenseTemplatesSyncHandler
    extends SyncTableHandler<$ExpenseTemplatesTable, ExpenseTemplate> {
  @override
  String get tableName => 'expense_templates';
  @override
  TableInfo<$ExpenseTemplatesTable, ExpenseTemplate> tableRef(AppDatabase db) =>
      db.expenseTemplates;
  @override
  Map<String, dynamic> toSyncPayload(ExpenseTemplate row) => {
    'id': row.id,
    'sourceId': row.sourceId,
    'sampleMessage': row.sampleMessage,
    'triggerWord': row.triggerWord,
    'amountPattern': row.amountPattern,
    'descriptionPattern': row.descriptionPattern,
    'datePattern': row.datePattern,
    'categoryId': row.categoryId,
    'selectedAmount': row.selectedAmount,
    'createdAt': row.createdAt.toUtc().toIso8601String(),
    'updatedAt': row.updatedAt.toUtc().toIso8601String(),
  };
  @override
  Insertable<ExpenseTemplate> fromSyncPayload(
    String id,
    Map<String, dynamic> data,
  ) => ExpenseTemplatesCompanion.insert(
    id: id,
    sourceId: _str(data, 'sourceId'),
    sampleMessage: _str(data, 'sampleMessage'),
    triggerWord: _str(data, 'triggerWord'),
    amountPattern: _str(data, 'amountPattern'),
    descriptionPattern: _optStr(data, 'descriptionPattern'),
    datePattern: _optStr(data, 'datePattern'),
    categoryId: _optStr(data, 'categoryId'),
    selectedAmount: _optStr(data, 'selectedAmount'),
    createdAt: _dt(data, 'createdAt'),
    updatedAt: _dt(data, 'updatedAt'),
  );
  @override
  Future<void> deleteById(AppDatabase db, String id) async => await (db.delete(
    db.expenseTemplates,
  )..where((t) => t.id.equals(id))).go();

  @override
  Future<int> countRows(AppDatabase db) async {
    final c = countAll();
    final query = db.selectOnly(db.expenseTemplates)..addColumns([c]);
    final result = await query.getSingle();

    return result.read(c) ?? 0;
  }

  @override
  Future<List<ExpenseTemplate>> fetchAll(AppDatabase db) =>
      db.select(db.expenseTemplates).get();

  static String _str(Map<String, dynamic> data, String key) => data[key] ?? '';
  static Value<String> _optStr(Map<String, dynamic> data, String key) =>
      data[key] != null ? Value(data[key] as String) : const Value.absent();
  static DateTime _dt(Map<String, dynamic> data, String key) =>
      data[key] != null
      ? DateTime.parse(data[key] as String).toLocal()
      : DateTime.now();
}
