import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;

enum CorpusDirection { debit, credit }

class SmsCorpusFixture {
  final String workbook;
  final int rowIndex;
  final String body;
  final String? sender;
  final double? dateSerial;

  const SmsCorpusFixture({
    required this.workbook,
    required this.rowIndex,
    required this.body,
    this.sender,
    this.dateSerial,
  });

  DateTime? get date {
    final s = dateSerial;
    if (s == null) return null;

    return DateTime.utc(
      1899,
      12,
      30,
    ).add(Duration(milliseconds: (s * 86400000).round()));
  }

  String get sourceId => '$workbook#$rowIndex';
}

class CorpusWorkbook {
  final String filename;
  final CorpusDirection direction;
  final int tableRowCount;
  final List<SmsCorpusFixture> fixtures;

  const CorpusWorkbook({
    required this.filename,
    required this.direction,
    required this.tableRowCount,
    required this.fixtures,
  });
}

Future<List<CorpusWorkbook>> loadSmsCorpus() async {
  final dataDir = _resolveDataDir();
  final dir = Directory(dataDir);
  if (!dir.existsSync()) {
    throw FileSystemException('corpus directory not found', dataDir);
  }

  final files =
      dir
          .listSync(recursive: false, followLinks: false)
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.xlsx'))
          .toList(growable: false)
        ..sort((a, b) => a.path.compareTo(b.path));

  if (files.isEmpty) {
    throw FileSystemException('no xlsx files found in corpus', dataDir);
  }

  return [for (final file in files) await _decodeOne(file)];
}

String _resolveDataDir() {
  final script = Platform.script.toFilePath();
  var dir = p.dirname(script);
  for (var i = 0; i < 8; i++) {
    final candidate = p.join(dir, 'test', 'data');
    if (Directory(candidate).existsSync()) return candidate;
    final parent = p.dirname(dir);
    if (parent == dir) break;
    dir = parent;
  }

  return 'test/data';
}

Future<CorpusWorkbook> _decodeOne(File file) async {
  final bytes = await file.readAsBytes();
  final filename = file.uri.pathSegments.last;

  final stem = filename.substring(0, filename.length - '.xlsx'.length);
  final direction = stem.toLowerCase().contains('debit')
      ? CorpusDirection.debit
      : CorpusDirection.credit;

  final excel = Excel.decodeBytes(bytes);
  final table = excel.tables.values.first;
  final tableRowCount = table.rows.length;
  final header = table.rows.first;
  final cols = _resolveColumns(header);

  if (cols.body == null) {
    throw FormatException(
      'workbook $filename has no recognisable SMS column in its header',
    );
  }

  final fixtures = <SmsCorpusFixture>[];
  for (var i = 1; i < tableRowCount; i++) {
    final row = table.rows[i];
    final body = stringOf(row, cols.body);
    if (body == null || body.isEmpty) continue;

    fixtures.add(
      SmsCorpusFixture(
        workbook: filename,
        rowIndex: i - 1,
        body: body,
        sender: stringOf(row, cols.sender),
        dateSerial: doubleOf(row, cols.date),
      ),
    );
  }

  return CorpusWorkbook(
    filename: filename,
    direction: direction,
    tableRowCount: tableRowCount,
    fixtures: fixtures,
  );
}

class _ColumnMap {
  final int? body;
  final int? sender;
  final int? date;

  const _ColumnMap({this.body, this.sender, this.date});
}

_ColumnMap _resolveColumns(List<Data?> header) {
  int? find(Set<String> needles) {
    for (var i = 0; i < header.length; i++) {
      final raw = header[i]?.value;
      if (raw == null) continue;
      final h = raw.toString().trim().toLowerCase();
      if (needles.contains(h)) return i;
    }

    return null;
  }

  return _ColumnMap(
    body: find({'sms', 'message', 'body'}),
    sender: find({'cardholders', 'sender', 'contactid', 'contact_id'}),
    date: find({'date', 'received_at', 'receivedat'}),
  );
}

String? stringOf(List<Data?> row, int? idx) {
  if (idx == null || idx >= row.length) return null;
  final v = row[idx]?.value;
  if (v == null) return null;

  return switch (v) {
    TextCellValue() => v.value.toString(),
    IntCellValue() => v.value.toString(),
    DoubleCellValue() => v.value.toString(),
    BoolCellValue() => v.value.toString(),
    DateCellValue() =>
      '${v.year.toString().padLeft(4, '0')}-'
          '${v.month.toString().padLeft(2, '0')}-'
          '${v.day.toString().padLeft(2, '0')}',
    DateTimeCellValue() => v.asDateTimeLocal().toIso8601String(),
    TimeCellValue() =>
      '${v.hour.toString().padLeft(2, '0')}:'
          '${v.minute.toString().padLeft(2, '0')}:'
          '${v.second.toString().padLeft(2, '0')}',
    FormulaCellValue() => v.formula,
  };
}

double? doubleOf(List<Data?> row, int? idx) {
  if (idx == null || idx >= row.length) return null;
  final v = row[idx]?.value;
  if (v == null) return null;

  return switch (v) {
    IntCellValue() => v.value.toDouble(),
    DoubleCellValue() => v.value,
    TextCellValue() => double.tryParse(v.value.text ?? v.value.toString()),
    _ => null,
  };
}
