import 'package:drift/drift.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get emoji => text().withDefault(const Constant('package'))();
  TextColumn get color => text().withDefault(const Constant('#2196F3'))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  TextColumn get categoryType => text().withDefault(const Constant('OUT'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
