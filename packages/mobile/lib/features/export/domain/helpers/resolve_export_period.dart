import '../entities/export_period.dart';
import '../entities/export_request.dart';

/// The period [request] covers on the day of [now]. Preset ranges run from
/// the first day of their first month to the end of today.
///
/// Requires `request.isValid`.
ExportPeriod resolveExportPeriod(ExportRequest request, DateTime now) {
  assert(request.isValid);
  final startOfTomorrow = DateTime(now.year, now.month, now.day + 1);

  // DateTime normalises month underflow: month 0 is December of the year
  // before.
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

  // Unreachable for a valid request.
  return const ExportPeriod();
}
