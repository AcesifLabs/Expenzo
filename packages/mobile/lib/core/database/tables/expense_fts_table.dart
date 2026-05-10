import 'package:drift/drift.dart';

@DataClassName('ExpenseFts')
class ExpenseFtsTable extends Table {
  @override
  String get tableName => 'expense_fts';

  TextColumn get expenseId => text()();
  TextColumn get description => text()();

  @override
  List<Set<Column>> get uniqueKeys => [];
}
