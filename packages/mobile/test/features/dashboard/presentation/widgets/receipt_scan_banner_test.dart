import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/receipt_scan_banner.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import '../../../../support/pump_localized.dart';

void main() {
  Future<void> pumpBanner(
    WidgetTester tester, {
    VoidCallback? onTap,
    AppLocale locale = AppLocale.en,
  }) => pumpLocalized(
    tester,
    Scaffold(body: ReceiptScanBanner(onTap: onTap)),
    locale: locale,
  );

  testWidgets('shows the label in English', (tester) async {
    await pumpBanner(tester);

    expect(find.text('Scan a receipt'), findsOneWidget);
  });

  testWidgets('shows the label in Bangla', (tester) async {
    await pumpBanner(tester, locale: AppLocale.bn);

    expect(find.text('রসিদ স্ক্যান করুন'), findsOneWidget);
  });

  testWidgets('tapping calls onTap once', (tester) async {
    var taps = 0;
    await pumpBanner(tester, onTap: () => taps++);

    await tester.tap(find.byType(ReceiptScanBanner));

    expect(taps, 1);
  });

  testWidgets('has a tap target at least 48 px high', (tester) async {
    await pumpBanner(tester, onTap: () {});

    expect(
      tester.getSize(find.byType(InkWell)).height,
      greaterThanOrEqualTo(AppSpacing.minTapTarget),
    );
  });

  testWidgets('is a button that reads as disabled without onTap', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpBanner(tester);

    await tester.tap(find.byType(ReceiptScanBanner));

    expect(
      tester.getSemantics(find.byType(ReceiptScanBanner)),
      matchesSemantics(
        label: 'Scan a receipt',
        isButton: true,
        hasEnabledState: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('does not overflow at 2x text scale in a narrow box', (
    tester,
  ) async {
    await pumpLocalized(
      tester,
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: Scaffold(
          body: Center(
            child: SizedBox(width: 320, child: ReceiptScanBanner(onTap: () {})),
          ),
        ),
      ),
      locale: AppLocale.bn,
    );

    expect(tester.takeException(), isNull);
  });
}
