import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/sms_parser/presentation/models/sms_scan_range_preset.dart';
import 'package:expense_tracker/features/sms_parser/presentation/models/sms_scan_range_selection.dart';
import 'package:expense_tracker/features/sms_parser/presentation/widgets/sms_scan_options_sheet.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('selects preset range and returns inclusive bounds', (
    tester,
  ) async {
    SmsScanRangeSelection? result;

    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showModalBottomSheet<SmsScanRangeSelection>(
                context: context,
                builder: (_) =>
                    SmsScanOptionsSheet(now: DateTime(2026, 7, 11, 18)),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Last 7 Days'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.preset, SmsScanRangePreset.last7Days);
    expect(result!.startDate, DateTime(2026, 7, 5));
    expect(result!.endDate, DateTime(2026, 7, 11));
  });

  testWidgets('uses custom range picker result when custom option tapped', (
    tester,
  ) async {
    SmsScanRangeSelection? result;

    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showModalBottomSheet<SmsScanRangeSelection>(
                context: context,
                builder: (_) => SmsScanOptionsSheet(
                  now: DateTime(2026, 7, 11, 18),
                  customRangePicker: (_) async => SmsScanRangeSelection(
                    preset: SmsScanRangePreset.custom,
                    startDate: DateTime(2026, 7, 1),
                    endDate: DateTime(2026, 7, 11),
                    label: 'Custom Range',
                  ),
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom date range'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.preset, SmsScanRangePreset.custom);
    expect(result!.startDate, DateTime(2026, 7, 1));
    expect(result!.endDate, DateTime(2026, 7, 11));
  });
}
