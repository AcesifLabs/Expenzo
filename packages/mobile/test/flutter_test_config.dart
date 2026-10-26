import 'dart:async';
import 'dart:io';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:talker/talker.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  appLogger.configure(settings: TalkerSettings(useConsoleLogs: false));
  if (const bool.fromEnvironment('LEAK_TRACKING')) {
    LeakTesting.enable();
    LeakTesting.settings = LeakTesting.settings.withIgnored(
      createdByTestHelpers: true,
      classes: [
        'TextPainter',
        'TapGestureRecognizer',
        'PanGestureRecognizer',
        'LongPressGestureRecognizer',

        'ValueNotifier<CurrencyInfo>',
        'ValueNotifier<NumberDisplayFormat>',

        'ImageStreamCompleterHandle',
      ],
    );

    tearDown(() {
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
