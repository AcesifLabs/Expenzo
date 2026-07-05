// ignore_for_file: prefer-match-file-name

import 'package:drift/drift.dart';

class PendingRecurring extends Table {
  TextColumn get id => text()();
  TextColumn get recurringId => text()();
  DateTimeColumn get dueDate => dateTime()();
  RealColumn get amount => real()();
  TextColumn get description => text()();
  TextColumn get categoryId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  Set<TableIndex> get indexes => {
    const TableIndex(
      name: 'idx_pending_recurring_req_id',
      columns: {#recurringId},
    ),
    const TableIndex(
      name: 'idx_pending_recurring_cat_id',
      columns: {#categoryId},
    ),
  };
}
