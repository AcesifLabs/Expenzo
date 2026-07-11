import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/sms_parser/presentation/helpers/sms_scan_range_presets.dart';
import 'package:expense_tracker/features/sms_parser/presentation/models/sms_scan_range_preset.dart';

void main() {
  group('buildPresetScanRange', () {
    final now = DateTime(2026, 7, 11, 18, 30);

    test('last 7 days includes today', () {
      final selection = buildPresetScanRange(
        preset: SmsScanRangePreset.last7Days,
        now: now,
      );

      expect(selection.startDate, DateTime(2026, 7, 5));
      expect(selection.endDate, DateTime(2026, 7, 11));
    });

    test('all time uses null bounds', () {
      final selection = buildPresetScanRange(
        preset: SmsScanRangePreset.allTime,
        now: now,
      );

      expect(selection.startDate, isNull);
      expect(selection.endDate, isNull);
    });
  });

  group('isValidCustomScanRange', () {
    test('accepts same-day range', () {
      expect(
        isValidCustomScanRange(
          startDate: DateTime(2026, 7, 11),
          endDate: DateTime(2026, 7, 11),
        ),
        isTrue,
      );
    });

    test('rejects incomplete or inverted ranges', () {
      expect(
        isValidCustomScanRange(
          startDate: DateTime(2026, 7, 12),
          endDate: DateTime(2026, 7, 11),
        ),
        isFalse,
      );
      expect(
        isValidCustomScanRange(startDate: DateTime(2026, 7, 11), endDate: null),
        isFalse,
      );
    });
  });
}
