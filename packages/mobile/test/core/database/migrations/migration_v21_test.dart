import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../generated/schema.dart';
import '../generated/schema_v20.dart' as v20;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v20 upgrades to exactly the schema a fresh install gets', () async {
    final db = AppDatabase.forTesting(await verifier.startAt(20));
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 21);
  });

  group('v20 data', () {
    late InitializedSchema schema;

    setUp(() async {
      schema = await verifier.schemaAt(20);
      final old = v20.DatabaseAtV20(schema.newConnection());
      await old.customStatement(
        "INSERT INTO parsing_rules (id, name, trigger_words, amount_pattern, "
        "source_type) VALUES ('rule-1', 'Bank', 'debited', '\\d+', 'sms')",
      );
      for (final (table, id) in [
        ('parsing_rules', 'rule-1'),
        ('records', 'r1'),
      ]) {
        await old.customStatement(
          'INSERT INTO sync_queue (entity_table, record_id, action, payload, '
          "created_at) VALUES (?, ?, 'insert', '{}', 0)",
          [table, id],
        );
      }
      await old.close();
    });

    Future<AppDatabase> migrated() async {
      final db = AppDatabase.forTesting(schema.newConnection());
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, 21);

      return db;
    }

    test('the matching rules table is gone', () async {
      final db = await migrated();
      final tables = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE name LIKE '%parsing_rules%'",
          )
          .get();

      expect(tables, isEmpty);
    });

    test('queued rule changes are dropped; other changes stay', () async {
      final db = await migrated();
      final queued = await db
          .customSelect('SELECT entity_table FROM sync_queue')
          .get();

      expect(queued.map((r) => r.read<String>('entity_table')), ['records']);
    });
  });
}
