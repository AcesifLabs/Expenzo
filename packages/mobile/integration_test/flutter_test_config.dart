import 'dart:async';

import 'package:integration_test/integration_test.dart';

/// Runs before every integration test file (`flutter test` looks for
/// `testExecutable`, not `main`).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await testMain();
}
