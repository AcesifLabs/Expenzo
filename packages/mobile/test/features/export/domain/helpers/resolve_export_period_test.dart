import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/export/domain/entities/export_period.dart';
import 'package:expense_tracker/features/export/domain/entities/export_request.dart';
import 'package:expense_tracker/features/export/domain/helpers/resolve_export_period.dart';

void main() {
  const all = {
    ExportContent.transactions,
    ExportContent.budgets,
    ExportContent.categories,
  };
  final june30 = DateTime(2026, 6, 30, 15, 45);

  ExportPeriod resolve(ExportRange range, DateTime now) =>
      resolveExportPeriod(ExportRequest(range: range, contents: all), now);

  test('all time has no bounds', () {
    expect(resolve(ExportRange.allTime, june30), const ExportPeriod());
  });

  test('this year starts Jan 1 and ends at the start of tomorrow', () {
    expect(
      resolve(ExportRange.thisYear, june30),
      ExportPeriod(start: DateTime(2026), end: DateTime(2026, 7)),
    );
  });

  test('last 6 months on 2026-06-30 starts 2026-01-01', () {
    expect(resolve(ExportRange.lastSixMonths, june30).start, DateTime(2026));
  });

  test('last 3 months on 2026-06-30 starts 2026-04-01', () {
    expect(
      resolve(ExportRange.lastThreeMonths, june30).start,
      DateTime(2026, 4),
    );
  });

  test('last 6 months on 2026-02-10 starts 2025-09-01', () {
    expect(
      resolve(ExportRange.lastSixMonths, DateTime(2026, 2, 10)),
      ExportPeriod(start: DateTime(2025, 9), end: DateTime(2026, 2, 11)),
    );
  });

  test('the end is exclusive and covers all of today', () {
    final end = resolve(ExportRange.lastThreeMonths, june30).end!;

    expect(DateTime(2026, 6, 30, 23, 59, 59).isBefore(end), isTrue);
    expect(end, DateTime(2026, 7));
  });

  test('custom range covers whole start and end days', () {
    final request = ExportRequest(
      range: ExportRange.custom,
      customStart: DateTime(2026, 3, 5, 18),
      customEnd: DateTime(2026, 3, 20, 9),
      contents: all,
    );

    expect(
      resolveExportPeriod(request, june30),
      ExportPeriod(start: DateTime(2026, 3, 5), end: DateTime(2026, 3, 21)),
    );
  });

  test('a one-day custom range is valid', () {
    final request = ExportRequest(
      range: ExportRange.custom,
      customStart: DateTime(2026, 3, 5),
      customEnd: DateTime(2026, 3, 5),
      contents: all,
    );

    expect(request.isValid, isTrue);
    expect(
      resolveExportPeriod(request, june30),
      ExportPeriod(start: DateTime(2026, 3, 5), end: DateTime(2026, 3, 6)),
    );
  });

  group('isValid is false', () {
    test('with no contents', () {
      const request = ExportRequest(range: ExportRange.allTime, contents: {});

      expect(request.isValid, isFalse);
    });

    test('for a custom range missing a date', () {
      final request = ExportRequest(
        range: ExportRange.custom,
        customStart: DateTime(2026, 3, 5),
        contents: all,
      );

      expect(request.isValid, isFalse);
    });

    test('for a custom range that starts after it ends', () {
      final request = ExportRequest(
        range: ExportRange.custom,
        customStart: DateTime(2026, 3, 6),
        customEnd: DateTime(2026, 3, 5, 23),
        contents: all,
      );

      expect(request.isValid, isFalse);
    });
  });
}
