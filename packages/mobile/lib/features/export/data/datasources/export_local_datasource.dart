import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import 'package:expense_tracker/core/database/daos/category_dao.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';

import '../../domain/entities/export_file.dart';
import '../../domain/entities/export_period.dart';
import '../../domain/helpers/resolve_export_period.dart';
import '../../domain/entities/export_request.dart';
import '../services/export_csv_builder.dart';

abstract class ExportLocalDatasource {
  Future<ExportFile> export(ExportRequest request, DateTime now);
}

class ExportLocalDatasourceImpl implements ExportLocalDatasource {
  final RecordDao recordDao;
  final CategoryDao categoryDao;
  final BudgetDao budgetDao;
  final Future<Directory> Function() tempDirectory;
  final Future<String> Function() currencyCode;
  final ExportCsvBuilder builder;

  static const _folderPrefix = 'expenzo_export_';

  const ExportLocalDatasourceImpl({
    required this.recordDao,
    required this.categoryDao,
    required this.budgetDao,
    required this.tempDirectory,
    required this.currencyCode,
    required this.builder,
  });

  @override
  Future<ExportFile> export(ExportRequest request, DateTime now) async {
    try {
      final records = await _readRecords(request, now);
      final (categories, budgets, currency) = await _readOthers(
        request.contents,
      );
      final payload = _ExportPayload(
        records: records,
        categories: categories,
        budgets: budgets,
        currencyCode: currency,
        contents: request.contents,
        builder: builder,
        folderPath: (await _freshFolder(now)).path,
        zipName: '$_folderPrefix${_date(now)}.zip',
      );

      return await Isolate.run(() => _writeFile(payload));
    } on EmptyExportException {
      rethrow;
    } catch (e, s) {
      appLogger.error('Export local datasource error', e, s);
      throw CacheException(message: e.toString());
    }
  }

  Future<List<Record>> _readRecords(ExportRequest request, DateTime now) async {
    if (!request.contents.contains(ExportContent.transactions)) return [];
    final period = resolveExportPeriod(request, now);
    final rows = switch (period) {
      ExportPeriod(start: final start?, end: final end?) =>
        await recordDao.getRecordsByDateRangeOnly(start, end),
      _ => await recordDao.getAllRecords(),
    };
    if (rows.isEmpty) throw const EmptyExportException();

    return rows.reversed.toList();
  }

  Future<(List<Category>, List<Budget>, String)> _readOthers(
    Set<ExportContent> contents,
  ) {
    final transactions = contents.contains(ExportContent.transactions);
    final needCategories =
        transactions || contents.contains(ExportContent.categories);
    final needBudgets =
        transactions || contents.contains(ExportContent.budgets);

    return (
      needCategories
          ? categoryDao.getAllCategories()
          : Future.value(const <Category>[]),
      needBudgets ? budgetDao.getAllBudgets() : Future.value(const <Budget>[]),
      transactions ? currencyCode() : Future.value(''),
    ).wait;
  }

  Future<Directory> _freshFolder(DateTime now) async {
    final temp = await tempDirectory();
    await _removeOldExports(temp);

    return Directory(
      p.join(temp.path, '$_folderPrefix${_date(now)}_${_time(now)}'),
    ).create(recursive: true);
  }

  static Future<void> _removeOldExports(Directory temp) async {
    await for (final entity in temp.list()) {
      final isExport = p.basename(entity.path).startsWith(_folderPrefix);
      if (entity is Directory && isExport) {
        await entity.delete(recursive: true);
      }
    }
  }

  static String _date(DateTime now) =>
      '${_pad(now.year, 4)}${_pad(now.month)}${_pad(now.day)}';

  static String _time(DateTime now) =>
      '${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';

  static String _pad(int value, [int width = 2]) =>
      value.toString().padLeft(width, '0');
}

class _ExportPayload {
  final List<Record> records;
  final List<Category> categories;
  final List<Budget> budgets;
  final String currencyCode;
  final Set<ExportContent> contents;
  final ExportCsvBuilder builder;

  final String folderPath;
  final String zipName;

  const _ExportPayload({
    required this.records,
    required this.categories,
    required this.budgets,
    required this.currencyCode,
    required this.contents,
    required this.builder,
    required this.folderPath,
    required this.zipName,
  });
}

ExportFile _writeFile(_ExportPayload payload) {
  final csvs = {
    for (final content in ExportContent.values)
      if (payload.contents.contains(content))
        _fileName(content): utf8.encode(_csv(content, payload)),
  };
  if (csvs.length == 1) {
    final MapEntry(key: name, value: bytes) = csvs.entries.single;

    return _save(payload.folderPath, name, bytes, ExportFile.csvMimeType);
  }
  final archive = Archive();
  for (final MapEntry(key: name, value: bytes) in csvs.entries) {
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  final zip = ZipEncoder().encode(archive) ?? const <int>[];

  return _save(
    payload.folderPath,
    payload.zipName,
    zip,
    ExportFile.zipMimeType,
  );
}

ExportFile _save(String folder, String name, List<int> bytes, String mime) {
  final path = p.join(folder, name);
  File(path).writeAsBytesSync(bytes, flush: true);

  return ExportFile(path: path, mimeType: mime);
}

String _fileName(ExportContent content) => switch (content) {
  ExportContent.transactions => 'transactions.csv',
  ExportContent.budgets => 'budgets.csv',
  ExportContent.categories => 'categories.csv',
};

String _csv(ExportContent content, _ExportPayload payload) {
  final builder = payload.builder;

  return switch (content) {
    ExportContent.transactions => builder.transactions(
      payload.records,
      categoriesById: {for (final c in payload.categories) c.id: c},
      budgetsById: {for (final b in payload.budgets) b.id: b},
      currencyCode: payload.currencyCode,
    ),
    ExportContent.budgets => builder.budgets(payload.budgets),
    ExportContent.categories => builder.categories(payload.categories),
  };
}
