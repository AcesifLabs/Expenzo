import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../generated/schema_v19.dart' as v19;

Future<void> addMissingV19Tables(
  QueryExecutor raw, {
  Set<String> except = const {},
}) async {
  final reference = v19.DatabaseAtV19(NativeDatabase.memory());
  final created = await reference
      .customSelect(
        "SELECT name, sql FROM sqlite_master "
        "WHERE type = 'table' AND sql IS NOT NULL "
        "AND name NOT LIKE 'sqlite_%'",
      )
      .get();
  await reference.close();

  final existing = {
    for (final row in await raw.runSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
      const [],
    ))
      row['name'] as String,
  };
  for (final row in created) {
    final name = row.read<String>('name');
    if (existing.contains(name) || except.contains(name)) continue;
    await raw.runCustom(row.read<String>('sql'), const []);
  }
}
