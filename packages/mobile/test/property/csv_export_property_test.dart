import 'package:csv/csv.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/features/export/data/services/export_csv_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';

import 'generators.dart';

const _formulaLeads = {'=', '+', '-', '@', '\t', '\r'};

void main() {
  late AppDatabase db;

  String safe(String text) =>
      text.isNotEmpty && _formulaLeads.contains(text[0]) ? "'$text" : text;

  property('exported text reads back as written, and never as a formula', () {
    forAll(
      list(combine2(anyText(maxLength: 30), everydayCents()), maxLength: 10),
      maxExamples: propertyTrials,
      setUp: () => db = AppDatabase.forTesting(NativeDatabase.memory()),
      tearDown: () => db.close(),
      (rows) async {
        await db.batch(
          (b) => b.insertAll(db.records, [
            for (final (i, (text, cents)) in rows.indexed)
              RecordsCompanion.insert(
                id: 'r${i.toString().padLeft(2, '0')}',
                amount: -cents / 100,
                description: text,
                date: DateTime(2026, 10, 1),
                recordType: 'OUT',
              ),
          ]),
        );
        final records = await (db.select(
          db.records,
        )..orderBy([(r) => OrderingTerm.asc(r.id)])).get();

        final encoded = const ExportCsvBuilder().transactions(
          records,
          categoriesById: const {},
          budgetsById: const {},
          currencyCode: 'BDT',
        );
        final decoded = Csv(
          autoDetect: false,
          skipEmptyLines: false,
        ).decode(encoded.replaceFirst('﻿', ''));

        final body = decoded.skip(1).toList();
        expect(body, hasLength(rows.length));

        for (final (i, (_, cents)) in rows.indexed) {
          expect(body[i][6], safe(records[i].description));
          expect(body[i][2], centsText(cents));
        }
        for (final cell in body.expand((row) => row).cast<String>()) {
          if (cell.isNotEmpty) expect(_formulaLeads, isNot(contains(cell[0])));
        }
      },
    );
  });
}
