import 'package:drift/drift.dart';
import '../../constants/source_types.dart';
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
    name: _str(data, 'name'),
    triggerWords: _str(data, 'triggerWords'),
    amountPattern: _str(data, 'amountPattern'),
    datePattern: _optStr(data, 'datePattern'),
    categoryId: _optStr(data, 'categoryId'),
    sourceType: data['sourceType'] ?? ExpenseSource.sms.name,
    isEnabled: _optBool(data, 'isEnabled'),
    priority: _optInt(data, 'priority'),
    createdAt: _dt(data, 'createdAt'),
    updatedAt: _dt(data, 'updatedAt'),
  );
  @override
  Future<void> deleteById(AppDatabase db, String id) async =>
      await (db.delete(db.parsingRules)..where((t) => t.id.equals(id))).go();

  @override
  Future<int> countRows(AppDatabase db) async {
    final c = countAll();
    final query = db.selectOnly(db.parsingRules)..addColumns([c]);
    final result = await query.getSingle();

    return result.read(c) ?? 0;
  }

  @override
  Future<List<ParsingRule>> fetchAll(AppDatabase db) =>
      db.select(db.parsingRules).get();

  static String _str(Map<String, dynamic> data, String key) => data[key] ?? '';
  static Value<String> _optStr(Map<String, dynamic> data, String key) =>
      data[key] != null ? Value(data[key] as String) : const Value.absent();
  static Value<bool> _optBool(Map<String, dynamic> data, String key) =>
      data[key] != null ? Value(data[key] as bool) : const Value.absent();
  static Value<int> _optInt(Map<String, dynamic> data, String key) =>
      data[key] != null
      ? Value(int.parse(data[key].toString()))
      : const Value.absent();
  static DateTime _dt(Map<String, dynamic> data, String key) =>
      data[key] != null
      ? DateTime.parse(data[key] as String).toLocal()
      : DateTime.now();
}
