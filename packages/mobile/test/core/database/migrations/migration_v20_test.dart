import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../generated/schema.dart';
import '../generated/schema_v19.dart' as v19;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v19 upgrades to exactly the schema a fresh install gets', () async {
    final db = AppDatabase.forTesting(await verifier.startAt(19));
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 20);
  });

  group('v19 data', () {
    late InitializedSchema schema;

    setUp(() async {
      schema = await verifier.schemaAt(19);
      final old = v19.DatabaseAtV19(schema.newConnection());
      Future<void> record(String id, {String? sourceId, String desc = 'x'}) =>
          old.customStatement(
            'INSERT INTO records (id, amount, description, date, source, '
            'source_id, record_type) VALUES (?, -10, ?, 0, ?, ?, ?)',
            [id, desc, sourceId == null ? 'manual' : 'sms', sourceId, 'OUT'],
          );
      await record('first', sourceId: 'sms-1', desc: 'Groceries at Agora');
      await record('copy', sourceId: 'sms-1', desc: 'Groceries at Agora');
      await record('other', sourceId: 'sms-2', desc: 'Taxi home');
      // A different message whose (hashed) id collided with 'other'.
      await record('collision', sourceId: 'sms-2', desc: 'Rent');
      await record('manual-a', desc: 'Lunch');
      await record('manual-b', desc: 'Lunch');
      await old.customStatement(
        "INSERT INTO sync_queue (entity_table, record_id, action, payload, "
        "created_at) VALUES ('records', 'manual-a', 'insert', '{}', 0)",
      );
      await old.customStatement(
        "INSERT INTO parsing_rules (id, name, trigger_words, amount_pattern, "
        "source_type) VALUES ('rule-1', 'Bank', 'debited', '\\d+', 'sms')",
      );
      await old.close();
    });

    Future<AppDatabase> migrated() async {
      final db = AppDatabase.forTesting(schema.newConnection());
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, 20);

      return db;
    }

    Future<List<String>> ids(AppDatabase db, String sql) async => [
      for (final row in await db.customSelect(sql).get())
        row.data.values.first.toString(),
    ];

    test('a duplicated SMS record keeps its first copy only', () async {
      final db = await migrated();

      expect(await ids(db, 'SELECT id FROM records ORDER BY id'), [
        'collision',
        'first',
        'manual-a',
        'manual-b',
        'other',
      ]);
    });

    test('a different message with a colliding id is kept, under its own '
        'id, and not deleted on the server', () async {
      final db = await migrated();
      final sourceIds = await ids(
        db,
        "SELECT source_id FROM records WHERE id IN ('other', 'collision') "
        'ORDER BY id',
      );

      expect(sourceIds.last, 'sms-2');
      expect(sourceIds.first, startsWith('sms-2#'));
      expect(
        await ids(
          db,
          "SELECT record_id FROM sync_queue WHERE action = 'delete'",
        ),
        isNot(contains('collision')),
      );
    });

    test('the removed copy is queued for deletion on the server', () async {
      final db = await migrated();

      expect(
        await ids(
          db,
          "SELECT record_id FROM sync_queue WHERE action = 'delete'",
        ),
        ['copy'],
      );
    });

    test('queued changes start with no failed attempts', () async {
      final db = await migrated();
      final row = await db
          .customSelect(
            "SELECT attempt_count, failed_at FROM sync_queue "
            "WHERE record_id = 'manual-a'",
          )
          .getSingle();

      expect(row.data, {'attempt_count': 0, 'failed_at': null});
    });

    test('existing rules read dates as day/month', () async {
      final db = await migrated();

      expect(await ids(db, 'SELECT date_order FROM parsing_rules'), ['dmy']);
    });

    test('search finds old records, and follows edits and deletes', () async {
      final db = await migrated();
      Future<List<String>> search(String term) => ids(
        db,
        'SELECT r.id FROM records r JOIN expense_fts f ON f.rowid = r.rowid '
        "WHERE expense_fts MATCH '$term' ORDER BY r.id",
      );

      expect(await search('groceries'), ['first']);

      await db.customStatement(
        "UPDATE records SET description = 'Fuel' WHERE id = 'other'",
      );
      await db.customStatement("DELETE FROM records WHERE id = 'first'");

      expect(await search('groceries'), isEmpty);
      expect(await search('taxi'), isEmpty);
      expect(await search('fuel'), ['other']);
    });

    test('an edit that keeps the description leaves search alone', () async {
      final db = await migrated();
      final trigger = await ids(
        db,
        "SELECT sql FROM sqlite_master WHERE name = 'records_au'",
      );

      expect(trigger.single, contains('WHEN old.description IS NOT'));

      await db.customStatement(
        "UPDATE records SET amount = -1 WHERE id = 'first'",
      );

      expect(
        await ids(
          db,
          'SELECT r.id FROM records r JOIN expense_fts f ON f.rowid = r.rowid '
          "WHERE expense_fts MATCH 'groceries'",
        ),
        ['first'],
      );
    });

    test('a second import of the same SMS is refused', () async {
      final db = await migrated();

      await expectLater(
        db.customStatement(
          'INSERT INTO records (id, amount, description, date, source, '
          "source_id, record_type) VALUES ('again', -10, 'x', 0, 'sms', "
          "'sms-2', 'OUT')",
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
