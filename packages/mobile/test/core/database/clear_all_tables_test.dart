import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart';

import '../../support/local_data_seed.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await seedLocalData(db);
  });

  tearDown(() => db.close());

  Future<int> rows(TableInfo<Table, Object?> table) async =>
      (await db.select(table).get()).length;

  test('keepUsers keeps the user and empties everything else', () async {
    await db.clearAllTables(keepUsers: true);

    expect(await rows(db.users), 1);
    for (final table in <TableInfo<Table, Object?>>[
      db.records,
      db.budgets,
      db.categories,
      db.recurringTransactions,
      db.messageSources,
      db.expenseTemplates,
      db.syncQueue,
    ]) {
      expect(await rows(table), 0, reason: table.actualTableName);
    }
  });

  test('the default call clears users too', () async {
    await db.clearAllTables();

    expect(await rows(db.users), 0);
    expect(await rows(db.records), 0);
  });
}
