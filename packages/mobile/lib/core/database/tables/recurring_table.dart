import 'package:drift/drift.dart';

class RecurringTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get frequency => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get nextOccurrence => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get autoCreateExpense =>
      boolean().withDefault(const Constant(true))();
  IntColumn get dayOfMonth => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
