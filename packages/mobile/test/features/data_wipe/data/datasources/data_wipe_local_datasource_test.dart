import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/sync/default_sync_registry.dart';
import 'package:expense_tracker/features/data_wipe/data/datasources/data_wipe_local_datasource.dart';
import 'package:expense_tracker/features/data_wipe/domain/entities/local_data_summary.dart';

import '../../../../support/local_data_seed.dart';

void main() {
  late AppDatabase db;
  late DataWipeLocalDatasourceImpl datasource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = DataWipeLocalDatasourceImpl(
      db: db,
      registry: createDefaultSyncRegistry(),
    );
  });

  tearDown(() => db.close());

  test('counts each kind of data', () async {
    await seedLocalData(
      db,
      records: 3,
      budgets: 2,
      categories: 4,
      recurring: 1,
      templates: 1,
      rules: 2,
    );

    expect(
      await datasource.countData(),
      const LocalDataSummary(
        transactions: 3,
        budgets: 2,
        categories: 4,
        recurring: 1,
        smsRules: 3,
      ),
    );
  });

  test('an empty database gives zeros and no goals row', () async {
    final summary = await datasource.countData();

    expect(
      summary,
      const LocalDataSummary(
        transactions: 0,
        budgets: 0,
        categories: 0,
        recurring: 0,
        smsRules: 0,
      ),
    );
    expect(summary.goals, isNull);
  });
}
