import 'package:drift/drift.dart';

@TableIndex(name: 'idx_records_date', columns: {#date})
@TableIndex(name: 'idx_records_budget_id', columns: {#budgetId})
@TableIndex(name: 'idx_records_user_id', columns: {#userId})
@TableIndex(name: 'idx_records_type_date', columns: {#recordType, #date})
@TableIndex(name: 'idx_records_category_date', columns: {#categoryId, #date})
@TableIndex.sql(
  'CREATE UNIQUE INDEX idx_records_source_unique ON records (source_id, source) '
  'WHERE source_id IS NOT NULL',
)
class Records extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  TextColumn get description => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get budgetId => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get sourceId => text().nullable()();
  TextColumn get recordType => text()();
  IntColumn get userId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
