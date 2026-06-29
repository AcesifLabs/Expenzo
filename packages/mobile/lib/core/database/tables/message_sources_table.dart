// ignore_for_file: prefer-match-file-name

import 'package:drift/drift.dart';

class MessageSources extends Table {
  TextColumn get id => text()();
  TextColumn get contactId => text()();
  TextColumn get contactName => text()();
  BoolColumn get isMonitored => boolean().withDefault(const Constant(false))();
  IntColumn get autoCreateOption => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
