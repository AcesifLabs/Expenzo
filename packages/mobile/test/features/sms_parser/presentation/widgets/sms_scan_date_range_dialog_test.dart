import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/sms_parser/presentation/models/sms_scan_range_selection.dart';
import 'package:expense_tracker/features/sms_parser/presentation/widgets/sms_scan_date_range_dialog.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('does not apply invalid inverted range', (tester) async {
    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => TextButton(
            onPressed: () {
              showDialog<SmsScanRangeSelection>(
                context: context,
                builder: (_) => SmsScanDateRangeDialog(
                  initialStartDate: DateTime(2026, 7, 12),
                  initialEndDate: DateTime(2026, 7, 11),
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

    expect(
      find.byKey(const Key('scan_range_validation_message')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('scan_range_apply_button')),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('applies valid same-day custom range', (tester) async {
    SmsScanRangeSelection? result;

    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showDialog<SmsScanRangeSelection>(
                context: context,
                builder: (_) => SmsScanDateRangeDialog(
                  initialStartDate: DateTime(2026, 7, 11),
                  initialEndDate: DateTime(2026, 7, 11),
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
    await tester.tap(find.byKey(const Key('scan_range_apply_button')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.startDate, DateTime(2026, 7, 11));
    expect(result!.endDate, DateTime(2026, 7, 11));
  });
}
