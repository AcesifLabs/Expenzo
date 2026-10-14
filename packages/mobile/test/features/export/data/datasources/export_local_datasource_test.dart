import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import 'package:expense_tracker/core/database/daos/category_dao.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/export/data/datasources/export_local_datasource.dart';
import 'package:expense_tracker/features/export/data/services/export_csv_builder.dart';
import 'package:expense_tracker/features/export/domain/entities/export_file.dart';
import 'package:expense_tracker/features/export/domain/entities/export_request.dart';

void main() {
  late AppDatabase db;
  late Directory temp;
  late ExportLocalDatasourceImpl datasource;
  final now = DateTime(2026, 6, 30, 14, 5, 9);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    temp = await Directory.systemTemp.createTemp('export_test_');
    datasource = ExportLocalDatasourceImpl(
      recordDao: RecordDao(db),
      categoryDao: CategoryDao(db),
      budgetDao: BudgetDao(db),
      tempDirectory: () async => temp,
      currencyCode: () async => 'BDT',
      builder: const ExportCsvBuilder(),
    );
  });

  tearDown(() async {
    await db.close();
    await temp.delete(recursive: true);
  });

  Future<void> addRecord(String id, DateTime date) => db
      .into(db.records)
      .insert(
        RecordsCompanion.insert(
          id: id,
          amount: -10,
          description: 'Record $id',
          date: date,
          recordType: 'OUT',
        ),
      );

  Future<void> addBudget() => db
      .into(db.budgets)
      .insert(
        BudgetsCompanion.insert(
          id: 'b1',
          name: 'Rent',
          amount: 5000,
          period: 'monthly',
          startDate: DateTime(2026),
        ),
      );

  ExportRequest request(
    Set<ExportContent> contents, {
    ExportRange range = ExportRange.allTime,
  }) => ExportRequest(range: range, contents: contents);

  /// The CSV rows of [bytes], after checking the UTF-8 BOM. `utf8.decode`
  /// drops the BOM itself.
  List<String> lines(List<int> bytes) {
    expect(bytes.take(3), [0xEF, 0xBB, 0xBF], reason: 'missing UTF-8 BOM');

    return utf8.decode(bytes).trim().split('\r\n');
  }

  List<FileSystemEntity> tempEntries() => temp.listSync();

  test('transactions only writes a single csv', () async {
    await addRecord('1', DateTime(2026, 6, 1));

    final file = await datasource.export(
      request({ExportContent.transactions}),
      now,
    );

    expect(file.mimeType, ExportFile.csvMimeType);
    expect(p.basename(file.path), 'transactions.csv');
    expect(p.basename(p.dirname(file.path)), 'expenzo_export_20260630_140509');
    expect(lines(File(file.path).readAsBytesSync()), hasLength(2));
  });

  test('all three contents produce a zip with three entries', () async {
    await addRecord('1', DateTime(2026, 6, 1));
    await addBudget();

    final file = await datasource.export(
      request(ExportContent.values.toSet()),
      now,
    );
    final archive = ZipDecoder().decodeBytes(File(file.path).readAsBytesSync());

    expect(file.mimeType, ExportFile.zipMimeType);
    expect(p.basename(file.path), 'expenzo_export_20260630.zip');
    expect(archive.files.map((f) => f.name), [
      'transactions.csv',
      'budgets.csv',
      'categories.csv',
    ]);
    expect(lines(archive.findFile('budgets.csv')!.content as List<int>), [
      'name,amount,period,start_date,rollover_enabled,rollover_amount,enabled',
      'Rent,5000.00,monthly,2026-01-01,false,0.00,true',
    ]);
  });

  test('range filters records by date with an exclusive end', () async {
    await addRecord('old', DateTime(2026, 2, 28, 23, 59));
    await addRecord('first', DateTime(2026, 4, 1));
    await addRecord('today', DateTime(2026, 6, 30, 23, 30));
    await addRecord('tomorrow', DateTime(2026, 7, 1));

    final file = await datasource.export(
      request({ExportContent.transactions}, range: ExportRange.lastThreeMonths),
      now,
    );
    final rows = lines(File(file.path).readAsBytesSync()).skip(1);

    expect(rows.map((row) => row.split(',')[6]), [
      'Record first',
      'Record today',
    ]);
  });

  test('transactions with an empty range throws and writes nothing', () async {
    await addRecord('old', DateTime(2025, 1, 1));
    await addBudget();

    await expectLater(
      datasource.export(
        request(ExportContent.values.toSet(), range: ExportRange.thisYear),
        now,
      ),
      throwsA(isA<EmptyExportException>()),
    );
    expect(tempEntries(), isEmpty);
  });

  test('budgets only with no records still writes budgets.csv', () async {
    await addBudget();

    final file = await datasource.export(request({ExportContent.budgets}), now);

    expect(p.basename(file.path), 'budgets.csv');
    expect(lines(File(file.path).readAsBytesSync()), hasLength(2));
  });

  test('an empty budgets table gives a header-only file', () async {
    final file = await datasource.export(request({ExportContent.budgets}), now);

    expect(lines(File(file.path).readAsBytesSync()), hasLength(1));
  });

  test('older export folders are removed', () async {
    await addBudget();
    final first = await datasource.export(
      request({ExportContent.budgets}),
      now,
    );
    final unrelated = Directory(p.join(temp.path, 'other'))..createSync();

    final second = await datasource.export(
      request({ExportContent.budgets}),
      now.add(const Duration(minutes: 1)),
    );

    expect(File(first.path).existsSync(), isFalse);
    expect(File(second.path).existsSync(), isTrue);
    expect(unrelated.existsSync(), isTrue);
  });

  test('a write error becomes CacheException', () async {
    final failing = ExportLocalDatasourceImpl(
      recordDao: RecordDao(db),
      categoryDao: CategoryDao(db),
      budgetDao: BudgetDao(db),
      tempDirectory: () async => throw const FileSystemException('read-only'),
      currencyCode: () async => 'BDT',
      builder: const ExportCsvBuilder(),
    );

    await expectLater(
      failing.export(request({ExportContent.budgets}), now),
      throwsA(isA<CacheException>()),
    );
  });

  test('a read error becomes CacheException', () async {
    await addRecord('1', DateTime(2026, 6, 1));
    await db.close();

    await expectLater(
      datasource.export(request({ExportContent.transactions}), now),
      throwsA(isA<CacheException>()),
    );
  });
}
