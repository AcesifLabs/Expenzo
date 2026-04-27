import 'package:drift/drift.dart';
import '../../constants/source_types.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get description => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get categoryId => integer().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get sourceId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<TableIndex> get indexes => [
    const TableIndex(name: 'idx_expenses_date', columns: {#date}),
    const TableIndex(name: 'idx_expenses_category', columns: {#categoryId}),
    const TableIndex(name: 'idx_expenses_source_id', columns: {#sourceId}),
  ];
}
