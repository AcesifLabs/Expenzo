import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/features/search/data/datasources/search_local_datasource.dart';
import 'package:expense_tracker/features/search/domain/entities/search_filters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';

import 'generators.dart';

void main() {
  late AppDatabase db;
  late SearchLocalDatasourceImpl search;

  Future<void> openDb() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    search = SearchLocalDatasourceImpl(db: db);
  }

  Future<void> insert(String id, String description) => db
      .into(db.records)
      .insert(
        RecordsCompanion.insert(
          id: id,
          amount: -10,
          description: description,
          date: DateTime(2026, 10, 1),
          recordType: 'OUT',
        ),
      );

  property('any search text runs against the real FTS5 index', () {
    forAll(
      anyText(),
      maxExamples: propertyTrials,
      setUp: openDb,
      tearDown: () => db.close(),
      (query) async {
        await insert('r1', 'Lunch at the corner shop');
        await search.searchRecords(SearchFilters(query: query));
      },
    );
  });

  property('a record is found by any word of its description', () {
    final words = string(
      minLength: 1,
      maxLength: 12,
      characterSet: CharacterSet.fromCharacters(
        'abcdefghijklmnopqrstuvwxyz0123456789টাকাবাজার',
      ),
    ).filter((word) => !word.startsWith('া'));

    forAll(
      combine3(words, words, words),
      maxExamples: propertyTrials,
      setUp: openDb,
      tearDown: () => db.close(),
      (v) async {
        final (first, second, third) = v;
        await insert('r1', '$first, $second "$third"');
        await insert('r2', 'something else entirely');

        final found = await search.searchRecords(SearchFilters(query: second));
        expect(found.map((r) => r.recordId), contains('r1'));
      },
    );
  });
}
