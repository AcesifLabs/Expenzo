import 'package:drift/drift.dart';
import '../database/app_database.dart';

abstract class SyncTableHandler<TTable extends Table, TRow extends DataClass> {
  String get tableName;
  TableInfo<TTable, TRow> tableRef(AppDatabase db);
  Map<String, dynamic> toSyncPayload(TRow row);
  Insertable<TRow> fromSyncPayload(String id, Map<String, dynamic> data);
  Future<void> deleteById(AppDatabase db, String id);
  Future<int> countRows(AppDatabase db);
  Future<List<TRow>> fetchAll(AppDatabase db);
}

class SyncTableRegistry {
  final Map<String, SyncTableHandler> _handlers = {};

  Iterable<SyncTableHandler> get all => _handlers.values;
  Iterable<String> get tableNames => _handlers.keys;

  void register(SyncTableHandler handler) {
    _handlers[handler.tableName] = handler;
  }

  SyncTableHandler? operator [](String tableName) => _handlers[tableName];
}
