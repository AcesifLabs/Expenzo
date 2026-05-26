import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../sync_table_registry.dart';

class ParsingRulesSyncHandler
    extends SyncTableHandler<$ParsingRulesTable, ParsingRule> {
  @override
  String get tableName => 'parsing_rules';
  @override
  TableInfo<$ParsingRulesTable, ParsingRule> tableRef(AppDatabase db) =>
      db.parsingRules;
  @override
  Map<String, dynamic> toSyncPayload(ParsingRule row) => {
    'id': row.id,
    'name': row.name,
    'triggerWords': row.triggerWords,
    'amountPattern': row.amountPattern,
    'datePattern': row.datePattern,
    'categoryId': row.categoryId,
    'sourceType': row.sourceType,
    'isEnabled': row.isEnabled,
    'priority': row.priority,
    'createdAt': row.createdAt.toUtc().toIso8601String(),
    'updatedAt': row.updatedAt.toUtc().toIso8601String(),
  };
  @override
  Insertable<ParsingRule> fromSyncPayload(
    String id,
    Map<String, dynamic> data,
  ) => ParsingRulesCompanion.insert(
    id: id,
    name: data['name'] ?? '',
    triggerWords: data['triggerWords'] ?? '',
    amountPattern: data['amountPattern'] ?? '',
    datePattern: data['datePattern'] != null
        ? Value(data['datePattern'])
        : const Value.absent(),
    categoryId: data['categoryId'] != null
        ? Value(data['categoryId'])
        : const Value.absent(),
    sourceType: data['sourceType'] ?? 'sms',
    isEnabled: data['isEnabled'] != null
        ? Value(data['isEnabled'])
        : const Value.absent(),
    priority: data['priority'] != null
        ? Value(int.parse(data['priority'].toString()))
        : const Value.absent(),
    createdAt: data['createdAt'] != null
        ? DateTime.parse(data['createdAt']).toLocal()
        : DateTime.now(),
    updatedAt: data['updatedAt'] != null
        ? DateTime.parse(data['updatedAt']).toLocal()
        : DateTime.now(),
  );
  @override
  Future<void> deleteById(AppDatabase db, String id) async =>
      await (db.delete(db.parsingRules)..where((t) => t.id.equals(id))).go();
  @override
  Future<int> countRows(AppDatabase db) async {
    final count = countAll();
    final query = db.selectOnly(db.parsingRules)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  @override
  Future<List<ParsingRule>> fetchAll(AppDatabase db) =>
      db.select(db.parsingRules).get();
}
