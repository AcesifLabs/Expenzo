import 'dart:async';
import 'dart:io';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:talker/talker.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';

/// Runs before every test file. Error-path tests make the code log on
/// purpose; keep the console for real failures.
///
/// Goldens: the CI images (text drawn as blocks) are the ones checked in.
/// Images with real text are only made locally with `GOLDENS_PLATFORM=true`,
/// since fonts render differently on each machine.
///
/// Leak tracking (`--dart-define=LEAK_TRACKING=true`) fails a widget test
/// that leaves a disposable object (controller, focus node, ...) undisposed.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  appLogger.configure(settings: TalkerSettings(useConsoleLogs: false));
  if (const bool.fromEnvironment('LEAK_TRACKING')) {
    LeakTesting.enable();
    LeakTesting.settings = LeakTesting.settings.withIgnored(
      // Objects the tests themselves make, like the tester's own views.
      createdByTestHelpers: true,
      classes: [
        // fl_chart's pie chart makes these for its labels and touches and
        // never disposes them (PieChartPainter.drawTexts, RenderBaseChart).
        'TextPainter',
        'TapGestureRecognizer',
        'PanGestureRecognizer',
        'LongPressGestureRecognizer',
        // CurrencyFormatter's static settings live as long as the app.
        'ValueNotifier<CurrencyInfo>',
        'ValueNotifier<NumberDisplayFormat>',
        // The image cache's keep-alive handle for an image still on screen
        // when the test ends; released with the cache, after this check.
        'ImageStreamCompleterHandle',
      ],
    );
    // Flutter's image cache keeps decoded asset images past the test that
    // showed them; emptying it disposes them.
    tearDown(() {
      // Plain unit tests have no binding, and no images.
      if (BindingBase.debugBindingType() == null) return;
      imageCache
        ..clear()
        ..clearLiveImages();
    });
  }
  final platformGoldens =
      Platform.environment['GOLDENS_PLATFORM'] == 'true' &&
      !Platform.environment.containsKey('CI');

  await AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(enabled: platformGoldens),
    ),
    run: () async => testMain(),
  );
}
