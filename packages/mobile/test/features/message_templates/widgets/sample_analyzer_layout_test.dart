import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_spacing.dart';

import '../../../support/core_screens.dart';
import '../../../support/more_screens.dart';
import '../../../support/pump_localized.dart';

void main() {
  setUp(registerScreenTestDependencies);
  tearDown(() => di.getIt.reset());

  testWidgets('the message list fills the screen below the info banner', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(720, 1440)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await pumpLocalized(tester, sampleAnalyzerScreen());
    await tester.pumpAndSettle();

    final listBottom = tester.getBottomLeft(find.byType(ListView)).dy;

    expect(listBottom, closeTo(720 - AppSpacing.md, 1));
  });
}
