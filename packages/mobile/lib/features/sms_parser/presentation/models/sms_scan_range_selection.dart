import 'sms_scan_range_preset.dart';

class SmsScanRangeSelection {
  final SmsScanRangePreset preset;
  final DateTime? startDate;
  final DateTime? endDate;

  const SmsScanRangeSelection({
    required this.preset,
    required this.startDate,
    required this.endDate,
  });
}
