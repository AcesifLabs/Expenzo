import 'package:drift/drift.dart';

class MessageSources extends Table {
  TextColumn get id => text()();
  TextColumn get contactId => text()();
  TextColumn get contactName => text()();
  BoolColumn get isMonitored => boolean().withDefault(const Constant(false))();
  IntColumn get autoCreateOption => integer().withDefault(
    const Constant(1),
  )(); // 0: autoCreate, 1: promptUser, 2: manualOnly
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
