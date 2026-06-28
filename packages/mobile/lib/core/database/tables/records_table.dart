import 'package:drift/drift.dart';
import '../../constants/source_types.dart';

class Records extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  TextColumn get description => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get source =>
      text().withDefault(Constant(ExpenseSource.manual.name))();
  TextColumn get sourceId => text().nullable()();
  TextColumn get recordType => text()();
  IntColumn get userId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  Set<TableIndex> get indexes => {
    const TableIndex(name: 'idx_records_date', columns: {#date}),
    const TableIndex(name: 'idx_records_category', columns: {#categoryId}),
    const TableIndex(name: 'idx_records_source_id', columns: {#sourceId}),
  };
}
