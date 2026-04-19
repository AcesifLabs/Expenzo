import 'package:drift/drift.dart';

class PendingRecurring extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recurringId => text()();
  DateTimeColumn get dueDate => dateTime()();
  RealColumn get amount => real()();
  TextColumn get description => text()();
  TextColumn get categoryId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
