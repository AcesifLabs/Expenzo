import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/features/search/data/datasources/search_local_datasource.dart';
import 'package:expense_tracker/features/search/domain/entities/search_filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SearchLocalDatasourceImpl datasource;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = SearchLocalDatasourceImpl(db: db);
    for (final (id, amount, type) in [
      ('rent', -250.0, 'OUT'),
      ('coffee', -40.0, 'OUT'),
      ('salary', 5000.0, 'IN'),
    ]) {
      await db
          .into(db.records)
          .insert(
            RecordsCompanion.insert(
              id: id,
              amount: amount,
              description: id,
              date: DateTime(2026, 10, 1),
              recordType: type,
            ),
          );
    }
  });

  tearDown(() => db.close());

  test('an amount range finds expenses, which are stored negative', () async {
    final results = await datasource.searchRecords(
      const SearchFilters(minAmount: 100, maxAmount: 500),
    );

    expect(results.map((r) => r.recordId), ['rent']);
  });

  test('a minimum alone finds large income and expenses', () async {
    final results = await datasource.searchRecords(
      const SearchFilters(minAmount: 200),
    );

    expect(results.map((r) => r.recordId).toSet(), {'rent', 'salary'});
  });
}
