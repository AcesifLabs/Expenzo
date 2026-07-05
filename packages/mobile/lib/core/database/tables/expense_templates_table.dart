// ignore_for_file: prefer-match-file-name

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
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  Set<TableIndex> get indexes => {
    const TableIndex(
      name: 'idx_expense_templates_source_id',
      columns: {#sourceId},
    ),
    const TableIndex(
      name: 'idx_expense_templates_cat_id',
      columns: {#categoryId},
    ),
  };
}
