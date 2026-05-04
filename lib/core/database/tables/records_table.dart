import 'package:drift/drift.dart';

class Records extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get description => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get categoryId => integer().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get sourceId => text().nullable()();
  TextColumn get recordType => text()(); // IN or OUT
  IntColumn get userId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  Set<TableIndex> get indexes => {
    const TableIndex(name: 'idx_records_date', columns: {#date}),
    const TableIndex(name: 'idx_records_category', columns: {#categoryId}),
    const TableIndex(name: 'idx_records_source_id', columns: {#sourceId}),
  };
}
