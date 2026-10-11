import '../models/sms_scan_range_preset.dart';
import '../models/sms_scan_range_selection.dart';

SmsScanRangeSelection buildPresetScanRange({
  required SmsScanRangePreset preset,
  required DateTime now,
}) {
  final today = DateTime(now.year, now.month, now.day);

  return switch (preset) {
    SmsScanRangePreset.last7Days => SmsScanRangeSelection(
      preset: preset,
      startDate: today.subtract(const Duration(days: 6)),
      endDate: today,
    ),
    SmsScanRangePreset.last30Days => SmsScanRangeSelection(
      preset: preset,
      startDate: today.subtract(const Duration(days: 29)),
      endDate: today,
    ),
    SmsScanRangePreset.last3Months => SmsScanRangeSelection(
      preset: preset,
      startDate: DateTime(today.year, today.month - 2, today.day),
      endDate: today,
    ),
    SmsScanRangePreset.allTime => const SmsScanRangeSelection(
      preset: SmsScanRangePreset.allTime,
      startDate: null,
      endDate: null,
    ),
    SmsScanRangePreset.custom => throw ArgumentError(
      'Custom range must be built from explicit dates.',
    ),
  };
}

bool isValidCustomScanRange({
  required DateTime? startDate,
  required DateTime? endDate,
}) {
  if (startDate == null || endDate == null) {
    return false;
  }

  final normalizedStart = DateTime(
    startDate.year,
    startDate.month,
    startDate.day,
  );
  final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);

  return !normalizedStart.isAfter(normalizedEnd);
}
