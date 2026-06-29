import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../sync_table_registry.dart';

class MessageSourcesSyncHandler
    extends SyncTableHandler<$MessageSourcesTable, MessageSource> {
  @override
  String get tableName => 'message_sources';
  @override
  TableInfo<$MessageSourcesTable, MessageSource> tableRef(AppDatabase db) =>
      db.messageSources;
  @override
  Map<String, dynamic> toSyncPayload(MessageSource row) => {
    'id': row.id,
    'contactId': row.contactId,
    'contactName': row.contactName,
    'isMonitored': row.isMonitored,
    'autoCreateOption': row.autoCreateOption,
    'createdAt': row.createdAt.toUtc().toIso8601String(),
    'updatedAt': row.updatedAt.toUtc().toIso8601String(),
  };
  @override
  Insertable<MessageSource> fromSyncPayload(
    String id,
    Map<String, dynamic> data,
  ) => MessageSourcesCompanion.insert(
    id: id,
    contactId: data['contactId'] ?? '',
    contactName: data['contactName'] ?? '',
    isMonitored: data['isMonitored'] != null
        ? Value(data['isMonitored'])
        : const Value.absent(),
    autoCreateOption: data['autoCreateOption'] != null
        ? Value(int.parse(data['autoCreateOption'].toString()))
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
      await (db.delete(db.messageSources)..where((t) => t.id.equals(id))).go();
  @override
  Future<int> countRows(AppDatabase db) async {
    final c = countAll();
    final query = db.selectOnly(db.messageSources)..addColumns([c]);
    final result = await query.getSingle();

    return result.read(c) ?? 0;
  }

  @override
  Future<List<MessageSource>> fetchAll(AppDatabase db) =>
      db.select(db.messageSources).get();
}
