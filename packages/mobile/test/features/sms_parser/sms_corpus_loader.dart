import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;

/// Direction encoded in the corpus workbook filename, e.g. `debit535` or
/// `credit121`. Used by tests to verify corpus integrity and to assert
/// per-row behaviour.
enum CorpusDirection { debit, credit }

/// One row from one workbook. [body] is the SMS text fed to the parser;
/// [dateSerial] is the workbook's column-E Excel serial retained as a
/// raw double — [date] resolves it into a UTC [DateTime] using the
/// standard 1899-12-30 base (the base that correctly compensates for
/// Excel's phantom 1900-feb-29 so serials ≥ 61 land on the right day).
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

  /// Stable id suitable for `sourceId` in [EvaluateRulesParams].
  String get sourceId => '$workbook#$rowIndex';
}

/// One workbook's worth of corpus rows. [tableRowCount] is the
/// authoritative size for cross-checks: the number of `sheetData/row`
/// elements in the file (including the header). [fixtures] excludes
/// the header and any rows whose SMS body came back empty.
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

/// Reads every `*.xlsx` file under `<package>/test/data/` and decodes
/// them as one [CorpusWorkbook] per file, sorted ascending by
/// filename.
///
/// Resolves the corpus directory by walking up from `Platform.script`
/// until `test/data` is found — this keeps the test independent of
/// the cwd `flutter test` happens to be launched from.
///
/// Relies on header names (not fixed column indices) so the
/// quirky c↔d column slice between header and data rows in the
/// on-disk workbooks doesn't shift our indices. Schema variants
/// currently recognised: header columns named one of `sms|message|body`
/// for the SMS text, one of `cardholders|sender|contact_id` for the
/// sender, one of `date|received_at` for the Excel serial date.
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
  // Prefer walking up from Platform.script so the loader works
  // regardless of where flutter test is invoked from.
  final script = Platform.script.toFilePath();
  var dir = p.dirname(script);
  for (var i = 0; i < 8; i++) {
    final candidate = p.join(dir, 'test', 'data');
    if (Directory(candidate).existsSync()) return candidate;
    final parent = p.dirname(dir);
    if (parent == dir) break;
    dir = parent;
  }

  // Fallback to cwd-relative. Works for `flutter test` from the
  // package root which is the standard invocation.
  return 'test/data';
}

Future<CorpusWorkbook> _decodeOne(File file) async {
  final bytes = await file.readAsBytes();
  final filename = file.uri.pathSegments.last;

  // Filename encoding also has a trailing number
  // (`01 - debit535 1896.xlsx`) but it is **not** a guaranteed row
  // count — the corpus's upstream tooling stamps its own metric, so
  // we deliberately do not encode it on the struct.
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
    // TextSpan.toString() flattens text + nested children, which
    // covers the simple "string in a cell" case the corpus uses.
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
