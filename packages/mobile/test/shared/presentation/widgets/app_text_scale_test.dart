import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/constants/app_font_size.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_text_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<double> scaled14(WidgetTester tester, double factor) async {
    late double result;
    await tester.pumpWidget(
      MaterialApp(
        home: AppTextScale(
          factor: factor,
          child: Builder(
            builder: (context) {
              result = MediaQuery.textScalerOf(context).scale(14);

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    return result;
  }

  testWidgets('Large makes 14 px text 16.1 px at device scale 1.0', (
    tester,
  ) async {
    expect(
      await scaled14(tester, AppFontSize.large.scale),
      closeTo(16.1, 1e-9),
    );
  });

  testWidgets('device 1.8 × Extra large is capped at the maximum', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    expect(
      await scaled14(tester, AppFontSize.extraLarge.scale),
      14 * AppConstants.maxTextScale,
    );
  });

  testWidgets('device 2.5 × Medium is capped at the maximum', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    expect(
      await scaled14(tester, AppFontSize.medium.scale),
      14 * AppConstants.maxTextScale,
    );
  });

  testWidgets('Small lowers text below the device scale', (tester) async {
    expect(
      await scaled14(tester, AppFontSize.small.scale),
      closeTo(12.6, 1e-9),
    );
  });
}
