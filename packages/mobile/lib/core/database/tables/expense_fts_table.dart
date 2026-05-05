import 'package:drift/drift.dart';

@DataClassName('ExpenseFts')
class ExpenseFtsTable extends Table {
  @override
  String get tableName => 'expense_fts';

  IntColumn get expenseId => integer()();
  TextColumn get description => text()();

  @override
  List<Set<Column>> get uniqueKeys => [];
}
