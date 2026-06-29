// ignore_for_file: prefer-match-file-name

import 'package:drift/drift.dart';

class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().nullable()();
  RealColumn get amount => real()();
  TextColumn get period => text()();
  DateTimeColumn get startDate => dateTime()();
  BoolColumn get rolloverEnabled =>
      boolean().withDefault(const Constant(false))();
  RealColumn get rolloverAmount => real().withDefault(const Constant(0.0))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get userId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
