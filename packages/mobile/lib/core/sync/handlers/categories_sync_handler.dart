import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../sync_table_registry.dart';
import 'sync_parse_helpers.dart';

class CategoriesSyncHandler
    extends SyncTableHandler<$CategoriesTable, Category> {
  @override
  String get tableName => 'categories';
  @override
  TableInfo<$CategoriesTable, Category> tableRef(AppDatabase db) =>
      db.categories;
  @override
  Map<String, dynamic> toSyncPayload(Category row) => {
    'id': row.id,
    'name': row.name,
    'emoji': row.emoji,
    'color': row.color,
    'isDefault': row.isDefault,
    'categoryType': row.categoryType,
    'usageCount': row.usageCount,
    'createdAt': row.createdAt.toUtc().toIso8601String(),
    'updatedAt': row.updatedAt.toUtc().toIso8601String(),
  };
  @override
  Insertable<Category> fromSyncPayload(String id, Map<String, dynamic> data) =>
      CategoriesCompanion.insert(
        id: id,
        name: parseSyncString(data['name'], 'Category'),
        emoji: data['emoji'] != null
            ? Value(parseSyncString(data['emoji']))
            : const Value.absent(),
        color: data['color'] != null
            ? Value(parseSyncString(data['color']))
            : const Value.absent(),
        isDefault: data['isDefault'] != null
            ? Value(data['isDefault'] == true)
            : const Value.absent(),
        categoryType: data['categoryType'] != null
            ? Value(parseSyncString(data['categoryType']))
            : const Value.absent(),
        usageCount: data['usageCount'] != null
            ? Value(int.tryParse(data['usageCount'].toString()) ?? 0)
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
      await (db.delete(db.categories)..where((t) => t.id.equals(id))).go();
  @override
  Future<int> countRows(AppDatabase db) async {
    final c = countAll();
    final query = db.selectOnly(db.categories)..addColumns([c]);
    final result = await query.getSingle();

    return result.read(c) ?? 0;
  }

  @override
  Future<List<Category>> fetchAll(AppDatabase db) =>
      db.select(db.categories).get();
}
