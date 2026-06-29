// ignore_for_file: prefer-match-file-name

import 'package:drift/drift.dart';

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityTable => text()();
  TextColumn get recordId => text()();
  TextColumn get action => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}
