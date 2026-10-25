import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/features/records/domain/filters/record_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late RecordDao dao;

  setUp(
    () => dao = RecordDao(db = AppDatabase.forTesting(NativeDatabase.memory())),
  );

  tearDown(() => db.close());

  Future<void> insert(String id, {String category = 'food', int day = 1}) => db
      .into(db.records)
      .insert(
        RecordsCompanion.insert(
          id: id,
          amount: -10,
          description: id,
          date: DateTime(2026, 10, day),
          recordType: 'OUT',
          categoryId: Value(category),
        ),
      );

  Stream<List<String>> watchIds(RecordFilter filter) => dao
      .watchFilteredRecords(filter)
      .map((rows) => [for (final row in rows) row.id]);

  test('sends only matching rows, and again when one is added', () async {
    await insert('lunch');
    await insert('bus', category: 'transport');
    final emissions = <List<String>>[];
    final sub = watchIds(
      const RecordFilter(categoryIds: ['food']),
    ).listen(emissions.add);
    addTearDown(sub.cancel);

    await pumpEventQueue();
    await insert('dinner', day: 2);
    await insert('taxi', category: 'transport', day: 3);
    await pumpEventQueue();

    expect(emissions.first, ['lunch']);
    expect(emissions.last, ['dinner', 'lunch']);
  });

  test('keeps to the limit, newest first', () async {
    for (var day = 1; day <= 5; day++) {
      await insert('r$day', day: day);
    }

    expect(await watchIds(const RecordFilter(limit: 3)).first, [
      'r5',
      'r4',
      'r3',
    ]);
  });
}
