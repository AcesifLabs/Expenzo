import '../entities/export_period.dart';
import '../entities/export_request.dart';

ExportPeriod resolveExportPeriod(ExportRequest request, DateTime now) {
  assert(request.isValid);
  final startOfTomorrow = DateTime(now.year, now.month, now.day + 1);

  return switch (request.range) {
    ExportRange.allTime => const ExportPeriod(),
    ExportRange.thisYear => ExportPeriod(
      start: DateTime(now.year),
      end: startOfTomorrow,
    ),
    ExportRange.lastSixMonths => ExportPeriod(
      start: DateTime(now.year, now.month - 5),
      end: startOfTomorrow,
    ),
    ExportRange.lastThreeMonths => ExportPeriod(
      start: DateTime(now.year, now.month - 2),
      end: startOfTomorrow,
    ),
    ExportRange.custom => _customPeriod(request),
  };
}

ExportPeriod _customPeriod(ExportRequest request) {
  if (request case ExportRequest(
    customStart: final first?,
    customEnd: final last?,
  )) {
    return ExportPeriod(
      start: DateTime(first.year, first.month, first.day),
      end: DateTime(last.year, last.month, last.day + 1),
    );
  }

  return const ExportPeriod();
}
