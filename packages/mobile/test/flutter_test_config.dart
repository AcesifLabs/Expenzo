import 'dart:async';

import 'package:talker/talker.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';

/// Runs before every test file. Error-path tests make the code log on
/// purpose; keep the console for real failures.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  appLogger.configure(settings: TalkerSettings(useConsoleLogs: false));
  await testMain();
}
