import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/export/data/datasources/export_local_datasource.dart';
import 'package:expense_tracker/features/export/data/repositories/export_repository_impl.dart';
import 'package:expense_tracker/features/export/domain/entities/export_file.dart';
import 'package:expense_tracker/features/export/domain/entities/export_request.dart';
import 'package:expense_tracker/features/export/domain/usecases/export_data.dart';

class _MockDatasource extends Mock implements ExportLocalDatasource {}

void main() {
  const request = ExportRequest(
    range: ExportRange.allTime,
    contents: {ExportContent.transactions},
  );
  const file = ExportFile(
    path: '/tmp/transactions.csv',
    mimeType: ExportFile.csvMimeType,
  );
  final now = DateTime(2026, 6, 30, 12);

  late _MockDatasource datasource;
  late ExportData exportData;

  setUpAll(() => registerFallbackValue(request));

  setUp(() {
    datasource = _MockDatasource();
    exportData = ExportData(
      ExportRepositoryImpl(localDatasource: datasource, clock: () => now),
    );
  });

  test('returns the datasource file on success', () async {
    when(() => datasource.export(any(), any())).thenAnswer((_) async => file);

    expect(await exportData(request), const Right<Failure, ExportFile>(file));
  });

  test('EmptyExportException becomes EmptyExportFailure', () async {
    when(
      () => datasource.export(any(), any()),
    ).thenThrow(const EmptyExportException());

    expect(
      await exportData(request),
      const Left<Failure, ExportFile>(EmptyExportFailure()),
    );
  });

  test('CacheException becomes CacheFailure', () async {
    when(
      () => datasource.export(any(), any()),
    ).thenThrow(const CacheException(message: 'disk full'));

    final result = await exportData(request);

    expect(
      result.fold((failure) => failure, (_) => null),
      isA<CacheFailure>().having((f) => f.message, 'message', 'disk full'),
    );
  });

  test('passes the request and the clock time to the datasource', () async {
    when(() => datasource.export(any(), any())).thenAnswer((_) async => file);

    await exportData(request);

    verify(() => datasource.export(request, now)).called(1);
  });
}
