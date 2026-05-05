import 'package:drift/drift.dart';
import 'message_sources_table.dart';

class ExpenseTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get sourceId => text().references(MessageSources, #id)();
  TextColumn get sampleMessage => text()();
  TextColumn get triggerWord => text()();
  TextColumn get amountPattern => text()();
  TextColumn get descriptionPattern => text().nullable()();
  TextColumn get datePattern => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get selectedAmount => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
