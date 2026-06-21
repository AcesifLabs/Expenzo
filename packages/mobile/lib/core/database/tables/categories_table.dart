import 'package:drift/drift.dart';
import '../../constants/record_type.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get emoji => text().withDefault(const Constant('package'))();
  TextColumn get color => text().withDefault(const Constant('#2196F3'))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  TextColumn get categoryType =>
      text().withDefault(Constant(RecordType.expense.dbValue))();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  IntColumn get userId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
