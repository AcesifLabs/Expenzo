import 'package:drift/drift.dart';

@TableIndex(name: 'idx_categories_user_id', columns: {#userId})
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get emoji => text().withDefault(const Constant('package'))();
  TextColumn get color => text().withDefault(const Constant('#2196F3'))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  TextColumn get categoryType =>
      // A literal (RecordType.expense.dbValue), as in records_table.dart.
      text().withDefault(const Constant('OUT'))();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  IntColumn get userId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
